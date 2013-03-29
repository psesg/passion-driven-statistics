require 'rubygems'
require 'ratistics'
require 'ratistics_charts'
#require 'ratistics_charts_js'

def display(collection, count=10)
  count.times do |i|
    if block_given?
      pp yield(collection[i])
    else
      pp collection[i]
    end
  end
end

file = File.join(__dir__, 'data/marscrater_pds.csv')

definition = [
  :crater_id,
  nil,
  [:latitude_circle_image, :to_f],
  nil,
  [:diam_circle_image, :to_f],
  [:depth_rimfloor_topog, :to_f]
]

puts 'Loading crater data...'
craters = Ratistics::Load::Csv.file(file, :def => definition, :headers => true)

puts 'Sorting crater data...'
craters.sort_by!{|crater| crater[:crater_id]}
craters.freeze

puts "Latitude..."
nearest_latitude = Ratistics.frequency(craters, :as => :catalog){|crater| crater[:latitude_circle_image].abs.floor}
nearest_latitude.sort!{|datum| datum.first}

Ratistics::Chart::Histogram.simple_histogram('Latitude of Crater Center (nearest whole degree)', nearest_latitude, :from => :catalog)

puts "Diameter..."
diam_circle_image = Ratistics.frequency(craters, :as => :catalog){|crater| (crater[:diam_circle_image]).floor}
diam_circle_image.sort!{|datum| datum.first}

Ratistics::Chart::Histogram.simple_histogram('Crater Diameter (in km)', diam_circle_image, :from => :catalog)

puts "Depth..."
depth_meters = Ratistics.frequency(craters, :as => :catalog){|crater| (crater[:depth_rimfloor_topog] * 1000).floor}
depth_meters.sort!{|datum| datum.first}

Ratistics::Chart::Histogram.simple_histogram('Average Elevation of Crater Rim (in meters)', depth_meters, :from => :catalog)

puts "Univariate data for Latitude..."
lat = Ratistics.collect(craters){|crater| crater[:latitude_circle_image].abs.floor}
n = lat.length
mean = Ratistics.mean(lat)
stddev = Ratistics.stddev(lat)
variance = Ratistics.variance(lat)
sum = Ratistics.sum(lat)
puts "N: #{n}"
puts "Mean: #{mean}"
puts "Std Deviation: #{stddev}"
puts "Variance: #{variance}"
puts "Sum Observations: #{sum}"

puts 'Done.'
