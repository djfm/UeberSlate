module ApplicationHelper
  
  include ActiveSupport::Inflector
  include FayeHelper
  
  def row object, options
    
    source_fields = options[:fields]
    source_fields = [source_fields] if source_fields.class != Array
    
    fields, classes  = [], []
    
    source_fields.each do |f|
      if f.class == Symbol or f.class == String
        fields  << object.send(f)
        classes << "#{underscore object.class}_#{f}"
      elsif f.class == Proc
        result = f.call(object)
        fields << result[:field]
        classes << "#{underscore object.class}_#{result[:class]}"
      end
    end
    
    render :partial => 'row', :locals => {:object => object, :fields => fields, :classes => classes}
  end
  
  def list objects, options
    
    source_fields = options[:fields]
    source_fields = [source_fields] if source_fields.class != Array
    
    fields, classes = [],[]
    
    source_fields.each do |f|
      if f.class == Symbol or f.class == String
        fields  << f
        classes << "#{underscore objects.first.class}_#{f}"
      elsif f.class == Proc
        fields  << '<i>(computed)</i>'.html_safe
        classes << 'default'
      end
    end
    
    
    render :partial => 'list', :locals => {:objects => objects, :options => options, :headers => fields, :classes => classes}
  end
  
end
