require 'rubygems'
require 'anemone'
require 'pry'
require 'mysql'

class Anemone::Page 
  def in_domain?(uri)
    same_domain = uri.host == @url.host

    if (!same_domain && (uri.host == 'www.xxx.org' or uri.host == 'www.xxx.com.br' or uri.host == 'xxx.org'))

      external_url = {
       referer: {
         host: self.url.host, path: self.url.path, url: self.url.to_s
       },
       host: uri.host,
       path: uri.path,
       url: uri.to_s
      }
      
      links = db['links']
      links.insert external_url
    end

    same_domain
  end
end

Não deveria estar aqui
db = Mongo::Connection.new.db('anemone')
links = db['links_sum']

links.find.each do |f|
  if (!black_list.include? f['links_sum.host'])
    uri = 'http://' + f['links_sum.host']
    puts uri
    # Primeira Passada
    #    crawl = Anemone.crawl("http://www.xxx.org/", {
    # Segunda Passada
      crawl = Anemone.crawl(uri, {
        :depth_limit => 2,
        :threads => 10,
        :discard_page_bodies => true
      }) do |anemone|
      anemone.storage = Anemone::Storage.MongoDB
      anemone.on_every_page do |page|
        title = page.doc.at('title').inner_html rescue nil
        puts "#{title} (#{page.depth})"
      end
    end
  end
end

puts "EOF"