module Helpers
  def create_image(version)
    
    puts "Building image..."
    @image = Docker::Image.build_from_dir("#{version}/")
    @image.tag("repo" => "node", "tag" => "#{version}", "force" => true)
    

    set :os, :family => 'debian'
    set :backend, :docker
    set :docker_image, @image.id
    
    puts "Running tests..."
  end
  
  def delete_image
    puts "Deleting image..."
    # Stop and remove only containers created from this image
    Docker::Container.all(:all => true).each do |container|
      container_image = container.info['Image']
      container_image_id = container.info['ImageID']
      
      # Match image IDs - container IDs may have sha256: prefix and be full hashes
      # while @image.id is the short ID
      if container_image&.include?(@image.id) || container_image_id&.include?(@image.id)
        begin
          container.stop unless container.info['State'] == 'exited'
          container.delete(:force => true)
        rescue Docker::Error::NotModifiedError
          # Container already stopped, ignore
        end
      end
    end
    
    @image.remove(:force => true)
  end
end

