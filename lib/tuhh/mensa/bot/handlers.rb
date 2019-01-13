# coding: utf-8
require "tuhh/mensa/scraper"

module TUHH::Mensa::Bot::Handlers; end

class TUHH::Mensa::Bot::Handlers::Default
  def initialize(config)
    @config = config
    @scraper = TUHH::Mensa::Scraper.new(config)
  end

  def on_start(user, message)
    resp = Hash.new
    resp[:en] = <<~"EOF"
      Hello.

      Type /now to display the current menu.
      Type /next to display the upcoming menu.

      Type /about to view an icon legend.
      Type /en or /de to switch the language.

      If shit hits the fan, please inform #{@config.fetch(:owner)}.
      EOF

    resp[:de] = <<~"EOF"
      Hallo.

      Sende /now für das aktuelle Menü.
      Sende /next für das nächste Menü.

      Sende /about für eine Symbol-Legende.
      Sende /en oder /de, um die Sprache zu wechseln.

      Falls etwas nicht geht, ist #{@config.fetch(:owner)} schuld.
      EOF

    resp
  end

  def on_about(user, message)
    resp = Hash.new
    resp[:en] = "Legend:\n"
    @scraper.icons[:en].each { |desc, emoji|
      resp[:en] << "#{desc}: #{emoji}\n"
    }

    resp[:de] = "Legende:\n"
    @scraper.icons[:de].each { |desc, emoji|
      resp[:de] << "#{desc}: #{emoji}\n"
    }

    resp
  end

  def on_de(user, message)
    user.lang = :de

    text = <<~"EOF"
      Sprache aktualisiert.

      Use /en to switch back to English.
      EOF

    {en: text, de: text}
  end

  def on_en(user, message)
    user.lang = :en

    text = <<~"EOF"
      Updated language preference.

      Für Deutsch bitte /de schicken.
      EOF

    {en: text, de: text}
  end

  def on_now(user, message)
    # Return the plan in user language only,
    # for performance and bandwidth reasons
    {user.lang => @scraper.show(:now, user.lang)}
  end

  def on_next(user, message)
    # see on_now
    {user.lang => @scraper.show(:next, user.lang)}
  end

  def default(user, message)
    {
      en: "I was unable to understand you :/",
      de: "Ich konnte dich leider nicht verstehen :/"
    }
  end
end
