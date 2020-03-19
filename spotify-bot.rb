#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'telegram/bot'
require 'rspotify'

Bundler.require

raise "Need SPOT_UID env var set" unless ENV['SPOT_UID']

TOKEN = ENV['TOKEN']
RSpotify.authenticate(ENV['SPOT_CLIENT_ID'], ENV['SPOT_CLIENT_SECRET'])
ME = RSpotify::User.find(ENV['SPOT_UID'])

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when '/ping'
      bot.api.send_message(chat_id: message.chat.id, text: 'pong')
    when /#{URI::DEFAULT_PARSER.make_regexp}/
      begin
        url = message.text
        track = RSpotify::Track.find(url.split("/").last)
        require 'pry'; binding.pry
        ME.queue(track)
      rescue StandardError => e
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Oops :( I had problem: #{e.class}; #{e.message}"
        )
      end
    end
  end
end
