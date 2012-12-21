require 'libarchive'
require 'fileutils'
require 'digest/md5'
require 'iconv'


module TranslationsAdapter
  
  include StringsHelper
  
  class Object::String
    def non_trivial?
      not trivial?
    end
    def trivial?
      strip.empty?
    end
  end
  
  class Object::NilClass
    def non_trivial?
      false
    end
    def trivial
      true
    end
  end
  
  #Returns an array of Hashes representing translations
  #
  #The array is comprised of Hashes of the form:
  #{'language_code' => 'xx', 'key' => 'xyz', 'string' => 'translation'}
  
  def self.adapt_archive file
    
    ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
    
    to_valid_utf8 = lambda do |untrusted_string|
      ic.iconv(untrusted_string + ' ')[0..-2]
    end
    
    path = file
    if file.class != String then path = file.path end
    
    translations = []
    
    Archive.read_open_filename path do |ar|
      while entry = ar.next_header
        name = entry.pathname
        if mailinfo = name.match(/(?:modules\/[^\/]+\/)?mails\/([a-z]{2})\/[^\.]+\.(html|txt)$/)
          language_code = mailinfo[1]
          body = ar.read_data
          translations << {'language_code' => language_code, 'key' => "mail_/#{mailinfo[0].gsub("/#{language_code}/", '/[iso]/')}", 'string' => to_valid_utf8.call(body)}       
        elsif
          (fileinfo = name.match(/\/([a-z]{2})\/(?:lang|tabs|admin|errors|fields|pdf|lang)\.php$/)) or (fileinfo = name.match(/\/([a-z]{2})\.php$/))
          language_code = fileinfo[1]
          exp = /\$\w+\s*\[\s*'((?:\\+'|[^'])+)'\s*\]\s*=\s*'((?:\\+'|[^'])+)'/
          ar.read_data.scan exp do |match|
            #puts "#{match[0]} :: #{match[1]}"
            key, string = match
            unless language_code.trivial? or key.trivial? or string.trivial?
              translations << {'language_code' => language_code, 'key' => key, 'string' => string}
            else
              puts "Translation is trivial: #{[language_code, key, string].join(', ')}"
            end
          end
        end
      end
      
    end
    
    return translations
    
  end
  
end