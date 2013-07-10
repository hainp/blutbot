#
# Copyright (C) 2013  Duong H. Nguyen (cmpitg_at_gmail_dot_com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
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

#
# This plugin is used to get info from a Github issue
#

#
# TODO:
# * Support more than Github
# * Support configuration per project
#

require 'nokogiri'
require 'open-uri'
require 'uri'

GITHUB_ISSUE = "https://github.com/\#{org_project}/issues/\#{issue_number}"

SELECTORS = {
  :title => '.discussion-topic-title',
  :state => 'span.state-indicator',
  :labels => 'span.filter-item.color-label',
  :assignee => 'span.js-assignee-infobar-item-wrapper',
  :n_participants => 'a[href="#pr_contributors_box"] strong',
  :participants => 'a.avatar.tooltipped.downwards',
}

class IssuePlugin < Plugin
  attr_accessor :page

  def name; "issue"; end

  def help(plugin, topic="")
    case topic
    when ""
      return _("""issue <command> [<tagnames>] <issue> => getting info about (an) issue(s) on Github. Valid <command>: `title`, `status`, `stats`, `labels`, `url`. Valid `url` must include `http` or `https`. If <command> is omitted, it's `status` by default. <issue> takes the form of `url` or `[organization] <project> <number>`, where <number> should be prefixed (but not necessary) with a `#`. Say `help issue <command>` for more info.""")

    when "status"
      return _("""issue status <issue> => getting title, participants, labels,
and open/closed status of an issue. Shorten form of this command:
istatus <issue>""")

    when "title"
      return _("""issue title <issue> => getting title of an issue.""")

    when "stats", "statistics"
      return _("""issue stats|statistics <issue> => getting number of open
(with urgent) and closed issues.""")

    when "labels"
      return _("""issue labels <tagname> <issue> => getting a list of open and
closed issues with their numbers and title matching tagname(s).  Multiple labels
are separated by a vertical bar '|'.""")

    when "url"
      return _("issue url <issue> => getting the full URL to the issue.")

    else
      return _("invalid topic, try: help issue")
    end
  end

  def url?(s)
    begin
      uri = URI.parse(string)
      %w(http https).include?(uri.scheme)
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
    end
  end

  def to_url(*issue)
    STDERR.puts "|#{issue}|"

    # Invalid issue format
    return "" if issue.length == 0

    # Issue format is already a URL
    return issue[0] if issue.length == 1 && url?(issue[0])

    # Otherwise: it has the format of ["[org/]project number"]
    org_project = issue[0]
    number = issue[1].gsub('#', '')
    STDERR.puts GITHUB_ISSUE.gsub("\#{org_project}", org_project)
                       .gsub("\#{issue_number}", number)
    return GITHUB_ISSUE.gsub("\#{org_project}", org_project)
                       .gsub("\#{issue_number}", number)
  end

  def get_issue_number(url)
    return /\/\d+$/.match(url).to_s
  end

  def get_title()
    @page.css(SELECTORS[:title])[0].children[0].content
  end

  def get_state()
    @page.css('span.state-indicator')[0].children[0].content.strip
  end

  def get_label()
    labels = @page.css('span.filter-item.color-label')
                  .map { |tag| tag.content }
    labels = ["development"] if labels.length == 0
    return labels
  end

  def get_assignees()
    assignee = @page.css(SELECTORS[:assignee])[0].children.css('a')
    if assignee.length == 0
      "no assignee"
    else
      assignee[0].children[0].content
    end
  end

  def get_n_participants()
    @page.css(SELECTORS[:n_participants])[0].children[0].content
  end

  def get_participants()
    @page.css(SELECTORS[:participants])
         .map { |tag| tag.attribute('title').content }
  end

  def get_labels()
    labels = @page.css('span.filter-item.color-label')
                  .map { |tag| tag.content }
    labels = ["development"] if labels.length == 0
    labels
  end

  def reply_each_line(m, message, timeout=0.1)
    message.each_line do |line|
      m.reply line
      sleep timeout
    end
  end

  def process_command(m, params)
    command = params[:command]
    url = to_url(*params[:issue])

    if url == ""
      m.reply "invalid issue format"
      return
    end

    @page = Nokogiri::HTML open(url)

    case command
    when "status"
      out = "=== issue #{get_issue_number(url).sub('/', '#')} ===\n"
      out << "url: #{url}\n"
      out << "title: #{get_title}\n"
      out << "state: #{get_state}\n"
      out << "label(s): #{get_labels.join(', ')}\n"
      out << "assignee(s): #{get_assignees}\n"
      out << "#{get_n_participants} participant(s): #{get_participants.join(', ')}\n"
      out << "=== end of issue ==="

    else
      out = "not implemented yet"
    end

    reply_each_line m, out
  end
end

plugin = IssuePlugin.new

# plugin.map "issue labels :labels *issue",
           # :action => :reply_labels,                            :thread => true
plugin.map "issue :command *issue",
           :action => :process_command,
           :thread => true
# plugin.map "issue title *issue",      :action => :reply_title,  :thread => true
# plugin.map "issue stats *issue",      :action => :reply_stats,  :thread => true
# plugin.map "issue statistics *issue", :action => :reply_stats,  :thread => true
# plugin.map "issue url *issue",        :action => :reply_url,    :thread => true
