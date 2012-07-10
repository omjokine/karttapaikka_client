# encoding: UTF-8

require 'open-uri'
require 'geocoder'

Geocoder.configure do |config|
  config.lookup = :bing
  config.api_key = "AjiRFAOxAb5Z01PMW3EwdUrCjDhN88QKPA3OfFmUuheW4ByTUZ9XPySvAv50RUpR"
  config.timeout = 30
end

open('http://www.alko.fi/myymala/liitetiedostot/myymalatfi/$File/myymos.txt') do |f|
  alkot = []

  f.readlines.each_with_index do |line, i|
    next if i < 3 # otsikot

    lols = line.split("\t")

    nimi = lols[0].encode("utf-8", "ISO8859-9")
    osoite = lols[1].encode("utf-8", "ISO8859-9")
    toimipaikka = lols[3].encode("utf-8", "ISO8859-9")
                          .capitalize
                          .gsub("Å", "å")
                          .gsub("Ä", "ä")
                          .gsub("Ö", "ö")

    lisatiedot = lols[14].encode("utf-8", "ISO8859-9").chop

    coordinates = Geocoder.search("#{osoite}, #{toimipaikka}")

    unless coordinates[0]
      if nimi.eql? "Hausjärvi Oitti"
        latitude = 60.788228
        longitude = 25.026907
      elsif nimi.eql? "Huittinen"
        latitude = 61.178483
        longitude = 22.697816
      elsif nimi.eql? "Kaarina Piikkiö"
        latitude = 60.425438
        longitude = 22.514333
      elsif nimi.eql? "Kajaani keskusta"
        latitude = 64.223279
        longitude = 27.735494
      elsif nimi.eql? "Kemiönsaari Dragsfjärd Taalintehdas"
        latitude = 60.019773
        longitude = 22.507101
      elsif nimi.eql? "Kemiönsaari Kemiö"
        latitude = 60.164102
        longitude = 22.735169
      elsif nimi.eql? "Kiiminki"
        latitude = 65.127426
        longitude = 25.779846
      elsif nimi.eql? "Kolari Ylläs Äkäslompolo"
        latitude = 67.604888
        longitude = 24.151804
      elsif nimi.eql? "Kouvola Valkeala"
        latitude = 60.881258
        longitude = 26.775643
      elsif nimi.eql? "Kuusamo Ruka"
        latitude = 66.168193
        longitude = 29.138112
      elsif nimi.eql? "Parainen"
        latitude = 60.308603
        longitude = 22.307738
      elsif nimi.eql? "Raasepori Tammisaari"
        latitude = 59.978401
        longitude = 23.441138
      elsif nimi.eql? "Seinäjoki Nurmo Prisma"
        latitude = 62.806469
        longitude = 22.878276
      elsif nimi.eql? "Sipoo Söderkulla"
        latitude = 60.297823
        longitude = 25.329257
      elsif nimi.eql? "Äänekoski Hirvaskangas"
        latitude = 62.516331
        longitude = 25.690079
      else
        puts "#{nimi}"
      end
    else
      latitude = coordinates[0].latitude
      longitude = coordinates[0].longitude
    end

    alkot += ([{"name" => nimi,
                "address" => osoite,
                "city" => toimipaikka,
                "info" => lisatiedot,
                "latitude" => latitude,
                "longitude" => longitude}])


#    puts "Nimi: #{nimi}, osoite: #{osoite}, toimipaikka: #{toimipaikka}, lisätiedot: #{lisatiedot}"
#    puts "lat: #{latitude}, lon: #{longitude}"
  end

  puts alkot.to_json
end
