module MotionDialog

	class GraphicsUtil
		
		# Creates a path for a rectangle with rounded corners
		# Return A CGPath that can be used to stroke the rounded rectangle
		def self.makeRoundedRectPath(rect, radius)
			minx = rect.origin.x
			midx = rect.origin.x + (rect.size.width) / 2
			maxx = rect.origin.x + rect.size.width
			miny = rect.origin.y
			midy = rect.origin.y + rect.size.height / 2
			maxy = rect.origin.y + rect.size.height
			path = CGPathCreateMutable()
			CGPathMoveToPoint(path, nil, minx, midy)
			CGPathAddArcToPoint(path, nil, minx, miny, midx, miny, radius)
			CGPathAddArcToPoint(path, nil, maxx, miny, maxx, midy, radius)
			CGPathAddArcToPoint(path, nil, maxx, maxy, midx, maxy, radius)
			CGPathAddArcToPoint(path, nil, minx, maxy, minx, midy, radius)
			CGPathCloseSubpath(path)
			path
		end
		
#		def self.fillRoundedRect(rect, inContext: context, withRadius: radius)
#		    CGContextBeginPath(context)
#		    CGContextSetGrayFillColor(context, 0.8, 0.5)
#		    CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect))
#		    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * Math::PI / 2, 0, 0)
#		    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, Math::PI / 2, 0)
#		    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, Math::PI / 2, Math::PI, 0)
#		    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, Math::PI, 3 * Math::PI / 2, 0)
#		    CGContextClosePath(context)
#		    CGContextFillPath(context)
#		end
		
		def self.fillRoundedRect(ctx, rect, radius)
			p = GraphicsUtil.makeRoundedRectPath(rect, radius)
			CGContextAddPath(ctx, p)
			CGContextFillPath(ctx)
		end
		
		def self.makeRoundedPath(size, radius)
			hsize = size / 2
			path = CGPathCreateMutable()
			CGPathMoveToPoint(path, nil, size, hsize)
			CGPathAddArcToPoint(path, nil, size, size, hsize, size, radius)
			CGPathAddArcToPoint(path, nil, 0, size, 0, hsize, radius)
			CGPathAddArcToPoint(path, nil, 0, 0, hsize, 0, radius)
			CGPathAddArcToPoint(path, nil, 0, size, hsize, radius)
			CGPathCloseSubpath(path)
			path
		end
	
	end #class

end #module