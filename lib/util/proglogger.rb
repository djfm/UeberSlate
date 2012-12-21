class Proglogger
  
  def initialize user_id=nil
    @user = User.find(user_id) if user_id
  end
  
  def start_task task, steps=0, interval=15
    end_task if @current_task
    log "Started task '#{task}', #{if steps > 0 then "#{steps} steps expected" else "expected duration unspecified" end}."
    @interval        = interval
    @current_task    = task
    @steps_completed = 0
    @steps_expected  = steps
    @started_at      = @last_ticked_at = Time.now
  end
  
  def end_task
    log "Task '#{@current_task}' completed in #{(Time.now - @started_at).seconds} seconds."
  end
  
  def progress_message
    completed = "#{@steps_completed} steps completed"
    if @steps_expected > 0
      completed = "#{((100.0*@steps_completed.to_f)/@steps_expected.to_f).round(1)}% completed"
    end
    "Progress on task '#{@current_task}': #{completed}."
  end
  
  def log message
    if @user
      @user.notify message
    end
    puts message
  end
  
  def step
    @steps_completed += 1
    if (Time.now - @last_ticked_at).seconds > @interval
      log progress_message
      @last_ticked_at = Time.now
    end
  end
  
end