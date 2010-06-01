require 'rubygems'
require 'switchboard'

settings = Switchboard::Settings.new
settings['pubsub.server'] = 'pubsub.xmpp.phonegap.com'
settings['jid'] = 'alice@xmpp.phonegap.com'
settings['password'] = ''
settings['pubsub.node'] = 'TestNode'

class TestJack
  def self.connect(switchboard, settings)
    switchboard.plug!(AutoAcceptJack, NotifyJack, DebugJack, PubSubJack)
    switchboard.hook(:book)
    switchboard.on_message do |message|
      if (message.body == 'subscribed')
        item = Jabber::PubSub::Item.new
        book = REXML::Element.new('book')
        book.add_namespace("pubsub:test:book")
        title = REXML::Element.new('title')
        title.text = "Cryponomicron"
        book << title
        item.add(book)
        puts item.to_s
        publish_item_to(settings['pubsub.node'], item);
      else
        stream.send(message.answer)
      end
    end

    switchboard.on_pubsub_event do |event|
      event.payload.each do |payload|
        payload.elements.each do |item|
          on(:book, item)
        end
      end
    end
  end

end

switchboard = Switchboard::Client.new(settings)
switchboard.plug!(TestJack)

switchboard.on_book do |book|
  puts "We see the book"
  msg = Jabber::Message.new('bob@xmpp.phonegap.com', 'test')
  stream.send(msg)
end

switchboard.run!

