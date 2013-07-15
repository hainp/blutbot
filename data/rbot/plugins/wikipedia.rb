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

class Wikipedia < Plugin
  def name; "My plugin"; end

  def help(plugin, topic="")
    case topic
    when "general"
      return _("Specific message")

    when "specific"
      return _("Specific message")
    end

    return _("Default message")
  end

  def method_to_call(m, params)
    # `m.reply` to reply
    # `m.sourcenick` = the sender
    # `@bot.nick` = nickname of the bot
    # `@bot.say sendee, message` = private message to sendee
    # `params` is a dictionary
  end
end

plugin = YourPlugin.new

plugin.map 'command :param [:optional_param]',
           :action => :method_to_call,
           :default => { :optional_param => "value" },
           :requirements => { :param => /who|what|where/ }

plugin.map 'command type2 *words',
           :action => :method_to_call