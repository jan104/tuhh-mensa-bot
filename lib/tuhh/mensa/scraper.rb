# coding: utf-8
require "http"
require "nokogiri"

module TUHH::Mensa; end

class TUHH::Mensa::Scraper
  def initialize(config)
    @config = config
  end

  def make_url(spec, lang)
    url = @config.dig(:urls, lang)
    puts "Built url: #{url}"
    year = Time.now.year

    case spec
    when :now
      url + "/#{year}/0/"
    when :next
      url + "/#{year}/99/"
    end
  end

  def fetch(spec, lang)
    url = make_url(spec, lang)
    [url, HTTP.get(url).to_s] # TODO: Error handling
  end

  def map_icon(img)
    case img.attr("alt")
    when /climate plate/i, /klima teller/i
      "🌲"
    when /vegetarian/i, /vegetarisch/i
      "🥕"
    when /vegan/i
      "Ⓥ"
    when /lactose-free/i, /laktosefrei/i
      "🚫🥛"
    when /mensa vital/i
      "🏋️"
    when /contains beef/i, /mit rind/i
      "🐮"
    when /contains pork/i, /mit schwein/i
      "🐷"
    when /contains poultry/i, /mit geflügel/i
      "🐔"
    else
      "X"
    end
  end

  def scrape(spec, lang)
    url, html = fetch(spec, lang)
    dom = Nokogiri::HTML(html)
    resp = String.new

    resp << dom.css("tr#headline th.category").first.text
    resp << "\n\n"

    dom.css("div#plan tr.odd, div#plan tr.even").each { |dish|
      description = dish.css(".dish-description").first
      label = description.text.strip

      # remove annoying allergens
      resp << label.gsub(/\s*\(.*?\)\s*/, "")

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
end
