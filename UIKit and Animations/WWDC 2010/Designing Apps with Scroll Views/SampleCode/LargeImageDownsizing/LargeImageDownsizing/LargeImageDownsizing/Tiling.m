////
////  Tiling.m
////  LargeImage
////
////  Created by Seyed Samad Gholamzadeh on 1/12/18.
////
//
//#import <Foundation/Foundation.h>
//
//- (void)saveTilesOfSize:(CGSize)size
//forImage:(UIImage*)image
//toDirectory:(NSString*)directoryPath
//usingPrefix:(NSString*)prefix
//{
//	CGFloat cols = [image size].width / size.width;
//	CGFloat rows = [image size].height / size.height;
//	
//	int fullColumns = floorf(cols);
//	int fullRows = floorf(rows);
//	
//	CGFloat remainderWidth = [image size].width -
//	(fullColumns * size.width);
//	CGFloat remainderHeight = [image size].height -
//	(fullRows * size.height);
//	
//	
//	if (cols > fullColumns) fullColumns++;
//	if (rows > fullRows) fullRows++;
//	
//	CGImageRef fullImage = [image CGImage];
//	
//	for (int y = 0; y < fullRows; ++y) {
//		for (int x = 0; x < fullColumns; ++x) {
//			CGSize tileSize = size;
//			if (x + 1 == fullColumns && remainderWidth > 0) {
//					// Last column
//				tileSize.width = remainderWidth;
//			}
//			if (y + 1 == fullRows && remainderHeight > 0) {
//					// Last row
//				tileSize.height = remainderHeight;
//			}
//			
//			CGImageRef tileImage = CGImageCreateWithImageInRect(fullImage,
//																(CGRect){{x*size.width, y*size.height},
//																	tileSize});
//			NSData *imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:tileImage]);
//			
//			CGImageRelease(tileImage);
//			
//			NSString *path = [NSString stringWithFormat:@"%@/%@%d_%d.png",
//							  directoryPath, prefix, x, y];
//			[imageData writeToFile:path atomically:NO];
//		}
//	}
//}
//
//
//#import <AppKit/AppKit.h>
//int main(int argc, const char * argv[]) {
//	@autoreleasepool
//	{
//			//handle incorrect arguments
//		if (argc < 2) {
//			NSLog(@"TileCutter arguments: inputfile");
//			return 0; }
//			//input file
//		NSString *inputFile = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
//			//tile size
//		CGFloat tileSize = 256; //output path
//		NSString *outputPath = [inputFile stringByDeletingPathExtension];
//			//load image
//		NSImage *image = [[NSImage alloc] initWithContentsOfFile:inputFile];
//		NSSize size = [image size];
//		NSArray *representations = [image representations]; if ([representations count])
//		{
//			NSBitmapImageRep *representation = representations[0]; size.width = [representation pixelsWide];
//			size.height = [representation pixelsHigh];
//		}
//		NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height); CGImageRef imageRef = [image CGImageForProposedRect:&rect
//																												 context:NULL hints:nil];
//			//calculate rows and columns
//		NSInteger rows = ceil(size.height / tileSize); NSInteger cols = ceil(size.width / tileSize);
//			//generate tiles
//		for (int y = 0; y < rows; ++y) {
//			for (int x = 0; x < cols; ++x) {
//					//extract tile image
//				CGRect tileRect = CGRectMake(x*tileSize, y*tileSize, tileSize, tileSize);
//				CGImageRef tileImage = CGImageCreateWithImageInRect(imageRef, tileRect);
//					//convert to jpeg data
//				NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:tileImage];
//				NSData *data = [imageRep representationUsingType: NSJPEGFileType properties:nil];
//				CGImageRelease(tileImage);
//					//save file
//				NSString *path = [outputPath stringByAppendingFormat: @"_%02i_%02i.jpg", x, y];
//				[data writeToFile:path atomically:NO]; }
//		} }
//	return 0; }
//
