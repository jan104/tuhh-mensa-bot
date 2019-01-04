require "http"
require "nokogiri"

module TUHH::Mensa; end

class TUHH::Mensa::Scraper
  def initialize(config)
    @config = config
  end

  def make_url(spec)
    url = @config.dig(:urls, :en) # TODO: Language selection
    year = Time.now.year

    case spec
    when :now
      url + "/#{year}/0/"
    when :next
      url + "/#{year}/99/"
    end
  end

  def fetch(spec)
    url = make_url(spec)
    [url, HTTP.get(url).to_s] # TODO: Error handling
  end

  def scrape(spec)
    url, html = fetch(spec)
    dom = Nokogiri::HTML(html)
    resp = String.new

    resp << dom.css("tr#headline th.category").first.text
    resp << "\n\n"

    dom.css("div#plan tr.odd, div#plan tr.even").each { |dish|
      resp << dish.css(".dish-description").first.text.strip
          .gsub(/\s*\(.*?\)\s*/, "") # Remove annoying allergens
      resp << ": "
      resp << dish.css(".price").first.text.strip
      resp << "\n"
    }
    resp << "\n" << url
    resp
  end

  def show(spec)
    scrape(spec)
  end
end
