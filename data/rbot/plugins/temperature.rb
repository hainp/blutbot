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

class TemperaturePlugin < Plugin
  def celcius_to_fahrenheit(m, params)
    unless params and params[:number]
      m.reply "inconnect usage: #{m.plugin}"
      return
    end

    num = params[:number].to_f
    m.reply(num * 1.8 + 32)
  end

  def fahrenheit_to_celcius(m, params)
    unless params and params[:number]
      m.reply "inconnect usage: #{m.plugin}"
      return
    end
    
    num = params[:number].to_f
    m.reply((num - 32) / 1.8)
  end

  def name
    "temperature"
  end

  def help(plugin, topic="")
    '''<unit_notation> <temperature>, where <unit_notation> is `ctof` or `ftoc` and <temperature> is the temperature to convert'''
  end
end

plugin = TemperaturePlugin.new

plugin.map 'ctof :number', :action => :celcius_to_fahrenheit
plugin.map 'ftoc :number', :action => :fahrenheit_to_celcius
