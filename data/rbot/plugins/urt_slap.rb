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

require 'string-irc'

class SlapPlugin < Plugin
  def help(plugin, topic="")
    case topic
    when ""
      return _("slap <nickname> => publicly slap a person\n" +
               "pslap <nickname> => privately slap a person")
    else
      return _("invalid help topic, try `help wiki`")
    end
  end

  def self.bold_text(s)
    "\x02" + s + "\x0f"
  end

  def self.slap_text()
    SlapPlugin.bold_text 'slapped'
  end

  def slap(m, params)
    if params[:nick].length == 0
      m.reply 'no nickname to slap'
      return
    end

    m.reply("#{params[:nick]} is #{SlapPlugin.slap_text} by the admin!")
  end

  def pslap(m, params)
    if params[:nick].length == 0
      m.reply 'no nickname to slap'
      return
    end

    @bot.say(params[:nick], "You are #{SlapPlugin.slap_text} by the admin!")
  end
end

plugin = SlapPlugin.new

plugin.map "slap :nick", :action => :slap, :thread => true
plugin.map "pslap :nick", :action => :pslap, :thread => true
