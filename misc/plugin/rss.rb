# $Id: rss.rb,v 1.4 2004-06-10 17:23:11 fdiary Exp $
# Copyright (C) 2003-2004 TAKEUCHI Hitoshi <hitoshi@namaraii.com>

def rss_recent_label
  '����������'
end

def rss(page_num = 10)

  pages = @db.page_info.sort do |a, b|
    k1 = a.keys[0]
    k2 = b.keys[0]
    b[k2][:last_modified] <=> a[k1][:last_modified]
  end

  n = 0
  item_list = ''
  last_modified = pages[0].values[0][:last_modified]

  items = <<EOS
<?xml version="1.0" encoding="#{$charset}" standalone="yes"?>
<rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <channel rdf:about="#{$index_page}?c=recent">
    <title>#{CGI::escapeHTML($site_name)} : #{rss_recent_label}</title>
    <link>#{$index_page}?c=recent</link>
    <description>#{CGI::escapeHTML($site_name)} #{rss_recent_label}</description>
    <language>ja</language>
    <copyright>Copyright (C) #{CGI::escapeHTML($author_name)}</copyright>
    <dc:date>#{last_modified.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")}</dc:date>
    <items>
      <rdf:Seq>
EOS

  pages.each do |p|
    break if (n += 1) > page_num
    name = p.keys[0]
    items << '        '

    uri = "#{$index_page}?#{name.escape}"
    items << %Q!<rdf:li resource="#{uri}"/>!

    item_list << <<EOS
    <item rdf:about="#{uri}">
    <title>#{CGI::escapeHTML(page_name(name))}</title>
    <link>#{uri}</link>
    <dc:date>#{p[name][:last_modified].utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")}</dc:date>
  </item>
EOS
  end

  items << <<EOS
      </rdf:Seq>
    </items>
  </channel>
EOS

  items << item_list << '</rdf:RDF>'

  header = Hash::new
  header['Last-Modified'] = CGI::rfc1123_date(last_modified)
  header['type']          = 'text/xml'
  header['charset']       =  $charset
  header['Content-Language'] = $lang
  header['Pragma']           = 'no-cache'
  header['Cache-Control']    = 'no-cache'
  print @cgi.header(header)
  puts items

  nil # Don't move to the 'FrontPage'
end

def rss_anchor(display_text = 'RSS')
  %Q!<a href="?c=rss">#{display_text}</a>!
end

add_body_enter_proc(Proc.new do
  add_plugin_command('rss', 'RSS')
end)
