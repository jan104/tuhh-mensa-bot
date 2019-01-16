# coding: utf-8
require "http"
require "nokogiri"

module TUHH::Mensa; end

class TUHH::Mensa::Scraper
  attr_reader :icons

  def initialize(config)
    @config = config
    @icons = load_icons
  end

  def scrape(spec, lang)
    url, html = fetch(spec, lang)
    dom = Nokogiri::HTML(html)
    resp = String.new

    resp << dom.css("tr#headline th.category").first.text
    resp << "\n\n"

    dom.css("div#plan tr.odd, div#plan tr.even").each { |dish|
      description = dish.css(".dish-description").first

      resp << process_label(description.text)
      icons = description.css("img").map { |img| map_icon(img) }
      resp << "\n    "
      resp << dish.css(".price").first.text.strip
      resp << " / #{icons.join(', ')}\n\n"
    }
    resp << "\n" << url
    resp
  end

  def show(spec, lang)
    scrape(spec, lang)
  end

  private
  def load_icons
    Psych.load_file(File.expand_path("../scraper/icons.yaml", __FILE__))
  end

  def make_url(spec, lang)
    url = @config.dig(:urls, lang)
    year = Time.now.year

    case spec
    when :now
      url + "/#{year}/0/"
    when :next
      url + "/#{year}/99/"
    end
  end

  def process_label(text)
    res = text
    res.strip!

    # Remove annoying allergens
    res.gsub!(/\s*\(.*?\)\s*/, "")

    # Fix wrong spacing around commas
    res.gsub!(/\s*?,\s*/, ", ")

    # Replace n-whitespace with a single space
    res.gsub!(/\s+/, " ")

    puts res
    res
  end

  def fetch(spec, lang)
    url = make_url(spec, lang)
    [url, HTTP.get(url).to_s] # TODO: Error handling
  end

  def map_icon(img)
    alt = img.attr("alt")
    @icons.each { |lang, icons|
      icons.each { |desc, emoji|
        re = /#{Regexp.quote(desc)}/i
        if alt =~ re
          return emoji
        end
      }
    }

    "X"
  end
end
