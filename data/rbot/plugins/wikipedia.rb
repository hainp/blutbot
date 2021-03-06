#
# Copyright (C) 2013  Duong H. Nguyen (cmpitg_at_gmail_dot_com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

require 'wikipedia'
require 'string-irc'
require 'cgi'

# Maximum number of results
MAX_N_RESULTS = 15

class WikipediaPlugin < Plugin
  def help(plugin, topic="")
    case topic
    when ""
      return _("wiki *words => search en.wikipedia" + "\n" +
               "wiki-stats <info> *words => get stats from a wiki page." +
               "<info> is one of: title, categories, links, extlinks, " +
               "images, image-url, image-descriptionurl, image-urls, " +
               "image-descriptionurls, coordinates.")
    else
      return _("invalid help topic, try `help wiki`")
    end
  end

  def self.get_paragraph(content, num=1)
    content.split("\n\n")
           .select {
             |line| not (line.start_with? "{{" or line.start_with? "[[")
           }
           .take(num).join('\n')
  end

  def self.ircify(s)
    s.gsub(/'''''([^']*?)'''''/, "\x02" + '\1' + "\x0f")
     .gsub(/'''([^']*?)'''/, "\x02" + '\1' + "\x0f")
     .gsub(/''([^']*?)''/, "\x02" + '\1' + "\x0f")
     .gsub(/\[\[([^\]]*?)\]\]/, '\1')
     .gsub(/\({{[^}]*?}}\)/, '')
     .gsub(/{{[^}]*?}}/, '')
     .gsub(/<ref[^>]*?>\s*?.*?\s*?<\/ref>/, '')
  end

  def self.get_disamb(content)
    WikipediaPlugin.get_paragraph(content) + content.split("\n\n")[1]
  end

  def reply_lines(m, text)
    text.lines do |line|
      m.reply line
      sleep 0.1
    end
  end

  def wiki(m, params)
    if params[:words].length == 0
      m.reply 'no keywords to search for'
      return
    end

    keyword = params[:words].join(' ')
    content = Wikipedia.find(keyword).content
    result = if not content
      "article not found"
    elsif content.end_with? '{{disambig}}'
      WikipediaPlugin.get_disamb content
    else
      WikipediaPlugin.get_paragraph content
    end

    m.reply "http://en.wikipedia.org/wiki/#{CGI.escape keyword}"
    reply_lines m, WikipediaPlugin.ircify(result)
    m.reply '--- EOM ---'
  end

  def wiki_stats(m, params)
    if params[:words].length == 0
      m.reply 'no keywords to search for'
      return
    end

    command = params[:command].gsub("-", "_").to_sym
    keyword = params[:words].join(' ')

    page = Wikipedia.find keyword
    info = page.send(command)
    result = ""

    if info.respond_to?(:take)
      info = info.take(MAX_N_RESULTS).each_with_index do |line, index|
        result << "#{index + 1}) #{line}\n"
      end
    else
      result = info
    end

    m.reply "http://en.wikipedia.org/wiki/#{CGI.escape keyword}"
    reply_lines m, result
    m.reply '--- EOM ---'
  end
end

plugin = WikipediaPlugin.new

plugin.map "wiki *words", :action => :wiki, :thread => true

plugin.map "wiki-stats :command *words",
           :requirements => {
             :command => /title|categories|links|extlinks||images|image-url|image-descriptionurl|image-urls|image-descriptionurls|coordinates/
           },
           :action => :wiki_stats,
           :thread => true
