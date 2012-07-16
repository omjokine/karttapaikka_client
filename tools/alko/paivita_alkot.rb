# encoding: UTF-8

require 'open-uri'
require 'geocoder'

Geocoder.configure do |config|
  config.lookup = :bing
  config.api_key = "AjiRFAOxAb5Z01PMW3EwdUrCjDhN88QKPA3OfFmUuheW4ByTUZ9XPySvAv50RUpR"
  config.timeout = 30
end

open('http://www.alko.fi/myymala/liitetiedostot/myymalatfi/$File/myymos.txt') do |f|
  alkot = {:alkos => []}

  f.readlines.each_with_index do |line, i|
    next if i < 3 # otsikot

    lols = line.split("\t")

    name = lols[0].encode("utf-8", "ISO8859-9")
    address = lols[1].encode("utf-8", "ISO8859-9")
    zip_code = lols[2]
    post_office = lols[3].encode("utf-8", "ISO8859-9")
                          .capitalize
                          .gsub("Å", "å")
                          .gsub("Ä", "ä")
                          .gsub("Ö", "ö")
    telephone = lols[4]
    email = lols[5]

    info = lols[14].encode("utf-8", "ISO8859-9").chop

    coordinates = Geocoder.search("#{address}, #{post_office}")

    unless coordinates[0]
      if name.eql? "Hausjärvi Oitti"
        latitude = 60.788228
        longitude = 25.026907
      elsif name.eql? "Huittinen"
        latitude = 61.178483
        longitude = 22.697816
      elsif name.eql? "Kaarina Piikkiö"
        latitude = 60.425438
        longitude = 22.514333
      elsif name.eql? "Kajaani keskusta"
        latitude = 64.223279
        longitude = 27.735494
      elsif name.eql? "Kemiönsaari Dragsfjärd Taalintehdas"
        latitude = 60.019773
        longitude = 22.507101
      elsif name.eql? "Kemiönsaari Kemiö"
        latitude = 60.164102
        longitude = 22.735169
      elsif name.eql? "Kiiminki"
        latitude = 65.127426
        longitude = 25.779846
      elsif name.eql? "Kolari Ylläs Äkäslompolo"
        latitude = 67.604888
        longitude = 24.151804
      elsif name.eql? "Kouvola Valkeala"
        latitude = 60.881258
        longitude = 26.775643
      elsif name.eql? "Kuusamo Ruka"
        latitude = 66.168193
        longitude = 29.138112
      elsif name.eql? "Parainen"
        latitude = 60.308603
        longitude = 22.307738
      elsif name.eql? "Raasepori Tammisaari"
        latitude = 59.978401
        longitude = 23.441138
      elsif name.eql? "Seinäjoki Nurmo Prisma"
        latitude = 62.806469
        longitude = 22.878276
      elsif name.eql? "Sipoo Söderkulla"
        latitude = 60.297823
        longitude = 25.329257
      elsif name.eql? "Äänekoski Hirvaskangas"
        latitude = 62.516331
        longitude = 25.690079
      else
        puts "#{name}"
      end
    else
      latitude = coordinates[0].latitude
      longitude = coordinates[0].longitude
    end

    alkot[:alkos] += ([{:name => name,
                        :address => address,
                        :post_ofice => post_office,
                        :zip_code => zip_code,
                        :telephone => telephone,
                        :email => email,
                        :info => info,
                        :latitude => latitude,
                        :longitude => longitude}])


#    puts "name: #{name}, address: #{address}, post_office: #{post_office}, lisätiedot: #{info}"
#    puts "lat: #{latitude}, lon: #{longitude}"
  end

  puts alkot.to_json
end
