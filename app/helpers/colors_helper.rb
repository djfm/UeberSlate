module ColorsHelper
  
  def rgb(arr)
    #puts "Arr: #{arr.inspect}"
    for i in 0...3
      arr[i] = if arr[i].nan? then 0 else arr[i].to_i end
    end
    "rgba(#{arr.join(",")})"
  end
  
  def gradient percent, from, to
    #puts "PFT: #{percent} #{from} #{to}"
    p = percent.to_f / 100.0
    
    color = from
    for i in 0...4
      color[i] += p * (to[i]-from[i])
    end
    
    rgb(color)
  end
end