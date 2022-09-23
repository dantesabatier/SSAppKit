//
//  NSBezierPath+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSBezierPath+SSAdditions.h"
#import <SSGraphics/SSContext.h>

static void CGPathCallback(void *info, const CGPathElement *element) {
	NSBezierPath *path = (__bridge NSBezierPath *)info;
	CGPoint *points = element->points;
	
	switch (element->type) {
		case kCGPathElementMoveToPoint: {
			[path moveToPoint:CGPointMake(points[0].x, points[0].y)];
			break;
		}
		case kCGPathElementAddLineToPoint: {
			[path lineToPoint:CGPointMake(points[0].x, points[0].y)];
			break;
		}
		case kCGPathElementAddQuadCurveToPoint: {
			// NOTE: This is untested.
			NSPoint currentPoint = path.currentPoint;
			NSPoint interpolatedPoint = CGPointMake((currentPoint.x + 2*points[0].x) / 3, (currentPoint.y + 2*points[0].y) / 3);
			[path curveToPoint:CGPointMake(points[1].x, points[1].y) controlPoint1:interpolatedPoint controlPoint2:interpolatedPoint];
			break;
		}
		case kCGPathElementAddCurveToPoint: {
			[path curveToPoint:CGPointMake(points[2].x, points[2].y) controlPoint1:CGPointMake(points[0].x, points[0].y) controlPoint2:CGPointMake(points[1].x, points[1].y)];
			break;
		}
		case kCGPathElementCloseSubpath: {
			[path closePath];
			break;
		}
	}
}

@implementation NSBezierPath(SSAdditions)

+ (instancetype)bezierPathWithRoundedRect:(CGRect)aRect corners:(SSRectCorner)corners radius:(CGFloat)radius {
    if (!radius) {
        return [self bezierPathWithRect:aRect];
    }
    
	NSBezierPath *path = self.bezierPath;
	radius = MIN(radius, 0.5 * MIN(CGRectGetWidth(aRect), CGRectGetHeight(aRect)));
	CGRect rect = NSInsetRect(aRect, radius, radius);
    
	if (corners & SSRectCornerBottomLeft) {
		[path appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)) radius:radius startAngle:180.0 endAngle:270.0];
	} else {
		NSPoint cornerPoint = CGPointMake(CGRectGetMinX(aRect), CGRectGetMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
    
	if (corners & SSRectCornerBottomRight) {
		[path appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect)) radius:radius startAngle:270.0 endAngle:360.0];
	} else {
		NSPoint cornerPoint = CGPointMake(CGRectGetMaxX(aRect), CGRectGetMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
    
	if (corners & SSRectCornerTopRight) {
		[path appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)) radius:radius startAngle:0.0 endAngle:90.0];
	} else {
		NSPoint cornerPoint = CGPointMake(CGRectGetMaxX(aRect), CGRectGetMaxY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
    
	if (corners & SSRectCornerTopLeft) {
		[path appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect)) radius:radius startAngle:90.0 endAngle:180.0];
	} else {
		NSPoint cornerPoint = CGPointMake(CGRectGetMinX(aRect), CGRectGetMaxY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
    
	[path closePath];
	return path;	
}

+ (instancetype)bezierPathWithRoundedRect:(CGRect)aRect radius:(CGFloat)radius {
	return [NSBezierPath bezierPathWithRoundedRect:aRect corners:SSRectAllCorners radius:radius];
}

+ (instancetype)bezierPathWithCGPath:(CGPathRef)pathRef {
	NSBezierPath *path = [NSBezierPath bezierPath];
	CGPathApply(pathRef, (__bridge void *)path, CGPathCallback);
	
	return path;
}

// Method borrowed from Google's Cocoa additions
- (CGPathRef)CGPath {
	CGMutablePathRef path = CGPathCreateMutable();
    
	NSInteger elementCount = self.elementCount;
	
	// The maximum number of points is 3 for a NSCurveToBezierPathElement.
	// (controlPoint1, controlPoint2, and endPoint)
	NSPoint controlPoints[3];
	
	for (NSInteger i = 0; i < elementCount; i++) {
		switch ([self elementAtIndex:i associatedPoints:controlPoints]) {
			case NSMoveToBezierPathElement:
				CGPathMoveToPoint(path, &CGAffineTransformIdentity, controlPoints[0].x, controlPoints[0].y);
				break;
			case NSLineToBezierPathElement:
				CGPathAddLineToPoint(path, &CGAffineTransformIdentity, controlPoints[0].x, controlPoints[0].y);
				break;
			case NSCurveToBezierPathElement:
				CGPathAddCurveToPoint(path, &CGAffineTransformIdentity, controlPoints[0].x, controlPoints[0].y, controlPoints[1].x, controlPoints[1].y, controlPoints[2].x, controlPoints[2].y);
				break;
			case NSClosePathBezierPathElement:
				CGPathCloseSubpath(path);
				break;
			default:
                NSLog(@"%@ %@, Warning!, unknown element…", self.class, NSStringFromSelector(_cmd));
				break;
		};
	}
	
	return SSAutorelease(path);
}

- (instancetype)pathWithStrokeWidth:(CGFloat)strokeWidth {
	NSBezierPath *path = [self copy];
	CGContextRef ctx = SSContextGetCurrent();
	CGPathRef pathRef = path.CGPath;
	[path release];
	
	CGContextSaveGState(ctx);
	
	CGContextBeginPath(ctx);
	CGContextAddPath(ctx, pathRef);
	CGContextSetLineWidth(ctx, strokeWidth);
	CGContextReplacePathWithStrokedPath(ctx);
	CGPathRef strokedPathRef = CGContextCopyPath(ctx);
	CGContextBeginPath(ctx);
	NSBezierPath *strokedPath = [NSBezierPath bezierPathWithCGPath:strokedPathRef];
	
	CGContextRestoreGState(ctx);
	CFRelease(strokedPathRef);
	
	return strokedPath;
}

- (void)applyInnerShadow:(NSShadow *)shadow {
	[NSGraphicsContext saveGraphicsState];
	
	NSShadow *shadowCopy = [shadow copy];
	
	CGSize offset = shadowCopy.shadowOffset;
	CGFloat radius = shadowCopy.shadowBlurRadius;
	
	CGRect bounds = NSInsetRect(self.bounds, -(ABS(offset.width) + radius), -(ABS(offset.height) + radius));
	
	offset.height += bounds.size.height;
	shadowCopy.shadowOffset = offset;
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy:0 yBy:([NSGraphicsContext currentContext].flipped ? 1 : -1) * bounds.size.height];
	
	NSBezierPath *drawingPath = [NSBezierPath bezierPathWithRect:bounds];
	drawingPath.windingRule = NSEvenOddWindingRule;
	
	[drawingPath appendBezierPath:self];
	[drawingPath transformUsingAffineTransform:transform];
	
	[self addClip];
	[shadowCopy set];
	
	[[NSColor blackColor] set];
	[drawingPath fill];
	
	[shadowCopy release];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (void)drawBlurWithColor:(NSColor *)color radius:(CGFloat)radius {
	CGRect bounds = NSInsetRect(self.bounds, -radius, -radius);
	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowOffset = CGSizeMake(0, bounds.size.height);
	shadow.shadowBlurRadius = radius;
	shadow.shadowColor = color;
	NSBezierPath *path = [self copy];
	NSAffineTransform *transform = [NSAffineTransform transform];
	if ([NSGraphicsContext currentContext].flipped)
		[transform translateXBy:0 yBy:bounds.size.height];
	else
		[transform translateXBy:0 yBy:-bounds.size.height];
	[path transformUsingAffineTransform:transform];
	
	[NSGraphicsContext saveGraphicsState];
	
	[shadow set];
	[[NSColor blackColor] set];
	NSRectClip(bounds);
	[path fill];
	
	[NSGraphicsContext restoreGraphicsState];
	
	[path release];
	[shadow release];
}

// Credit for the next two methods goes to Matt Gemmell
- (void)strokeInside {
    /* Stroke within path using no additional clipping rectangle. */
    [self strokeInsideWithinRect:CGRectZero];
}

- (void)strokeInsideWithinRect:(CGRect)clipRect {
    NSGraphicsContext *thisContext = [NSGraphicsContext currentContext];
    float lineWidth = self.lineWidth;
    
    /* Save the current graphics context. */
    [thisContext saveGraphicsState];
    
    /* Double the stroke width, since -stroke centers strokes on paths. */
    self.lineWidth = (lineWidth * 2.0);
    
    /* Clip drawing to this path; draw nothing outwith the path. */
    [self setClip];
    
    /* Further clip drawing to clipRect, usually the view's frame. */
    if (clipRect.size.width > 0.0 && clipRect.size.height > 0.0) {
        [NSBezierPath clipRect:clipRect];
    }
    
    /* Stroke the path. */
    [self stroke];
    
    /* Restore the previous graphics context. */
    [thisContext restoreGraphicsState];
    self.lineWidth = lineWidth;
}

+ (instancetype)bezierPathWithString:(NSString *)text inFont:(NSFont *)font {
	NSBezierPath *textPath = [self bezierPath];
	[textPath appendBezierPathWithString:text inFont:font];
	return textPath;
}

- (void)appendBezierPathWithString:(NSString *)text inFont:(NSFont *)font {
	if (self.empty)
        [self moveToPoint:NSZeroPoint];
	
	NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:text] autorelease];
	CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
	
	CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
	CFIndex count = CFArrayGetCount(glyphRuns);
	CFIndex index;
	for (index = 0; index < count; index++) {
		CTRunRef currentRun = CFArrayGetValueAtIndex(glyphRuns, index);
		
		CFIndex glyphCount = CTRunGetGlyphCount(currentRun);
		
		CGGlyph glyphs[glyphCount];
		CTRunGetGlyphs(currentRun, CTRunGetStringRange(currentRun), glyphs);
		
		NSGlyph bezierPathGlyphs[glyphCount];
		CFIndex glyphIndex;
		for (glyphIndex = 0; glyphIndex < glyphCount; glyphIndex++)
			bezierPathGlyphs[glyphIndex] = glyphs[glyphIndex];
		
		[self appendBezierPathWithGlyphs:bezierPathGlyphs count:glyphCount inFont:font];
	}
	
	CFRelease(line);
}

@end

void SSDrawStringAlignedInFrame(NSString *text, NSFont *font, NSTextAlignment alignment, CGRect frame) {
	NSCParameterAssert(font != nil);
	
	NSBezierPath *textPath = [NSBezierPath bezierPathWithString:text inFont:font];
	CGRect textPathBounds = CGRectMake(CGRectGetMinX(textPath.bounds), font.descender, CGRectGetWidth(textPath.bounds), font.ascender - font.descender);
	
	NSAffineTransform *scale = [NSAffineTransform transform];
	CGFloat xScale = CGRectGetWidth(frame)/CGRectGetWidth(textPathBounds);
	CGFloat yScale = CGRectGetHeight(frame)/CGRectGetHeight(textPathBounds);
	[scale scaleBy:MIN(xScale, yScale)];
	[textPath transformUsingAffineTransform:scale];
	
	textPathBounds.origin = [scale transformPoint:textPathBounds.origin];
	textPathBounds.size = [scale transformSize:textPathBounds.size];
	
	NSAffineTransform *originCorrection = [NSAffineTransform transform];
	NSPoint centeredOrigin = NSPointFromCGPoint(SSRectCenteredSize(frame, textPathBounds.size).origin);
	[originCorrection translateXBy:(centeredOrigin.x - CGRectGetMinX(textPathBounds)) yBy:(centeredOrigin.y - CGRectGetMinY(textPathBounds))];
	[textPath transformUsingAffineTransform:originCorrection];
	
	if (alignment != NSJustifiedTextAlignment && alignment != NSCenterTextAlignment) {
		NSAffineTransform *alignmentTransform = [NSAffineTransform transform];
		
		CGFloat deltaX = 0;
		if (alignment == NSLeftTextAlignment) deltaX = -(CGRectGetMinX(textPath.bounds) - CGRectGetMinX(frame));
		else if (alignment == NSRightTextAlignment) deltaX = (CGRectGetMaxX(frame) - CGRectGetMaxX(textPath.bounds));
		[alignmentTransform translateXBy:deltaX yBy:0];
		
		[textPath transformUsingAffineTransform:alignmentTransform];
	}
	
	[textPath fill];
}
