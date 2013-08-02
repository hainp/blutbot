require 'string-irc'

Rules =
  {
  '#1' => 'No racism of any kind',
  '#2' => 'No clan stacking, members must split evenly between the teams',
  '#3' => 'No arguing with admins (listen and learn or leave)',
  '#4' => 'No abusive language or behavior towards admins or other players',
  '#5' => 'No offensive or potentially offensive names, annoying names, or in-game (double caret (^)) color in names',
  '#6' => 'No recruiting for your clan, your server, or anything else',
  '#7' => 'No advertising or spamming of websites or servers',
  '#8' => 'No profanity or offensive language (in any language)',
  '#9' => 'Do NOT fire at teammates or within 10 seconds of spawning',
  '#10' => 'We do not tolerate hackers/cheaters on this server',
  '#11' => 'Do not accuse anybody of hacking/cheating without a DEMO!',
}

class WarnPlugin < Plugin
  def help(plugin, topic="")
    case topic
    when ""
      return _("w <nickname> [<rule>] => publicly warn a person\n" +
               "pw <nickname> [<rule>] => privately warn a person")
    else
      return _("invalid help topic, try `help wiki`")
    end
  end

  def self.bold_text(s)
    "\x02" + s + "\x0f"
  end

  def self.warn_text()
    WarnPlugin.bold_text 'WARNING'
  end

  def warn(m, params)
    if params[:nick].length == 0
      m.reply 'no nickname to warn'
      return
    end

    rule = params[:rule]

    if rule.length == 0
      m.reply 'no rule is given'
      return
    end

    text = Rules[rule]

    if !text
      m.reply("#{WarnPlugin.warn_text} #{params[:nick]}: #{rule} !")
      return
    end
    
    m.reply("#{WarnPlugin.warn_text} #{params[:nick]}: #{text} !")      
  end

  # Not in use
  def pwarn(m, params)
    if params[:nick].length == 0
      m.reply 'no nickname to warn'
      return
    end

    rule = params[:rule]  

    if rule.length == 0
      m.reply 'no rule is given'
      return
    end
   
    @bot.say(params[:nick], "#{WarnPlugin.warn_text}: #{rule}!")
  end
end
plugin = WarnPlugin.new

plugin.map "w :nick [:rule]", :action => :warn, :thread => true
# plugin.map "pw :nick [:rule]", :action => :pwarn, :thread => true
