require 'csv'

module MessagesAdapter
  def self.adapt_csv upload
    
    cgm = Hash.new{|h_cg,c| h_cg[c] = Hash.new {|h_g, g| h_g[g] = []}}
    
    data = ""
    if upload.class == String
      data = File.read(upload)
    else
      data = upload.read
    end
    
    #fix csv escape : \" => ""
    data.gsub! "\\\"","\"\""
    
    col_sep = data.count(';') > data.count(',') ? ';' : ','
    
    CSV.parse data, :col_sep => col_sep, :headers => true do |row|
      type = ""
      
      message  = {'language_code' => row["Language"], 'key' => row["Array Key"], 'string' => row["English String"]}
      category = row['Section'][/^(?:\s*\d+\s*-\s*)?(.*)$/,1].strip
      
      if category == 'Mails'
        if row['Storage File Path'] =~ /\.html$/
          type = "HTML"
        elsif row['Storage File Path'] =~ /\.txt$/
          type = "TXT"
        end
      end
      
      message['type'] = type
      
      storage = {
        'storage_method' => if row['Array Name'] then 'ARRAY' else 'FILE' end,
        'storage_path' => row['Storage File Path'].sub('/en/','/[iso]/').sub('/en.php','/[iso].php'),
        'storage_category' => category,
        'storage_custom' => row['Array Name']
      }
      
      message['storage'] = storage
      
      cgm[category][row['Group'].to_s] << message
      
    end
    
    return cgm
        
  end
  
  # Messages be like: {"Front-Office" => {"SomeGroup" => [{'key' => 'blah4587','string' => 'Hello', 'language_code' => 'en', 'type' => 'some_type', 'storage' => STORAGE}]}}
  #           the 'type' key is optional   
  # STORAGE is a hash containing storage info for the export of the pack, keys are: storage_method, storage_path, storage_category, storage_custom
  
  def self.adapt_module_archive path
    
    modname  = File.basename(path,File.extname(path)).downcase
    category = "Modules"
    group    = ""
    
    messages = {category => { group => []}}
    
    exps = {
      ".php" => /->l\s*\(\s*'((?:\\'|[^'])+)'\s*\)/,
      ".tpl" => /l\s+s\s*=\s*'((?:\\'|[^'])+)'/
      }
    
    Archive.read_open_filename path do |ar|
      while entry = ar.next_header
        if [".php",".tpl"].include?(ext = File.extname(entry.pathname))
          puts entry.pathname
          ar.read_data.scan(exp = exps[ext]) do |match|
            message = {
              'string' => match[0],
              'language_code' => 'en',
              'key' => "<{#{modname}}prestashop>#{File.basename(entry.pathname,ext).downcase}_#{Digest::MD5.hexdigest(match[0])}",
              'storage' => {
                'storage_method'   => "ARRAY",
                'storage_path'     => "/modules/#{modname}/[iso].php",
                'storage_category' => category,
                'storage_custom'   => "$_MODULE"
              }
            }
            messages[category][group] << message
          end
        end
      end
    end
    
    return messages
    
  end
  
end