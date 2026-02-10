module Helpers
  def create_image(version)
    puts "Building image..."
    
    begin
      @image = Docker::Image.build_from_dir("#{version}/")
    rescue Docker::Error::DockerError => e
      puts "Failed to build Docker image: #{e.message}"
      raise
    end

    set :os, :family => 'debian'
    set :backend, :docker
    set :docker_image, @image.id
    
    puts "Running tests..."
  end
  
  def delete_image
    return unless @image
    
    puts "Deleting image..."
    
    # Stop and remove only containers created from this image
    begin
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
          rescue Docker::Error::DockerError => e
            puts "Warning: Failed to cleanup container #{container.id[0..11]}: #{e.message}"
          end
        end
      end
    rescue Docker::Error::DockerError => e
      puts "Warning: Error during container cleanup: #{e.message}"
    end
    
    # Always attempt to remove the image, even if container cleanup failed
    begin
      @image.remove(:force => true)
      puts "Image removed successfully"
    rescue Docker::Error::NotFoundError
      puts "Image already removed"
    rescue Docker::Error::DockerError => e
      puts "Warning: Failed to remove image: #{e.message}"
    end
  end
end

