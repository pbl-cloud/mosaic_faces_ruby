#!/usr/bin/env ruby
# realtime_mosaic.rb
# 参考: http://blog.hello-world.jp.net/?p=1489

require "rubygems"
require "opencv"
include OpenCV
MOSAIC_SIZE = 15



def mosaic(image, rect, size)
	Range.new(rect.y, rect.y + rect.height).step(size) do |y|
		Range.new(rect.x, rect.x + rect.height).step(size) do |x|
			w = h = size
			w = (image.width - x) if x + size > image.width
			h = (image.height - y) if y + size > image.height
			top_left = CvPoint.new(x, y)
			bottom_right = CvPoint.new(x+w, y+h)
			avg = image.sub_rect(top_left, CvSize.new(w, h )).avg
			image.rectangle!(top_left, bottom_right, :color => avg, :thickness => -1)
		end
	end
end



##### Main #####

# read file
filename = nil
begin
	filename = ARGV[0]
	input = IplImage.load(filename)
rescue
	puts "ERROR! #{filename}"
	puts "Usage: ruby #{__FILE__} <filename>"
	exit
end
puts "input file: #{filename}"



# mosaic filter
detector = CvHaarClassifierCascade::load("./data/haarcascades/haarcascade_frontalface_alt.xml")
image = input
detector.detect_objects(image).each { |rect|
	mosaic(image, rect, MOSAIC_SIZE)
}

output_name = filename.split(".", -1)[0] + "_mosaic." + filename.split(".", -1)[1]
puts "output file: #{output_name}"
image.save_image(output_name)
