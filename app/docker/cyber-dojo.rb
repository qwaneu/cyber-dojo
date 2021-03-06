#!/usr/bin/env ruby

$me = 'cyber-dojo'
$my_dir = File.expand_path(File.dirname(__FILE__))

$docker_hub_username = 'cyberdojofoundation'
$home = '/usr/src/cyber-dojo'  # home folder *inside* the server image

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def help
  [
    '',
    "Use: #{$me} COMMAND",
    "     #{$me} help",
    '',
    '     up                   Creates and starts the server containers',
    '     down                 Stops and removes server containers',
    '',
    '     backup               Creates a tgz file of all practice sessions',
    '     catalog              Lists all language images',
    '     images               Lists pulled language images',
    '     pull [IMAGE|all]     Pulls one language IMAGE or all images',
    '     remove IMAGE         Removes a pulled language IMAGE',
    '     upgrade              Pulls the latest server and language images',
    ''
  ].join("\n") + "\n"
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def run(command)
  puts command
  `#{command}`
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def backup
  cmd = 'docker run' +
    ' --user=root' +
    ' --rm' +
    ' --volumes-from=cdf-katas-DATA-CONTAINER' +
    " --volume=/backup:/backup" +
    " #{$docker_hub_username}/web" +
    " tar -cvz -f /backup/cyber-dojo_katas_backup.tgz -C #{$home} katas"
  `#{cmd}`
  puts 'Created /backup/cyber-dojo_katas_backup.tgz'
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def up
  return unless languages == []
  puts 'No language images pulled'
  puts 'Pulling a small starting collection of common language images'
  starting = %w( gcc_assert gpp_assert csharp_nunit java_junit python_pytest ruby_mini_test )
  starting.each { |image| pull(image) }
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def catalog
  `#{$my_dir}/../languages/list_all_images.rb`
  # LANGUAGE          TESTS                IMAGE
  # Asm               assert               nasm_assert
  # BCPL              all_tests_passed     bcpl-all_tests_passed
  # Bash              shunit2              bash_shunit2
  # C (clang)         assert               clang_assert
  # C (gcc)           CppUTest             gcc_cpputest
  # ...
end

def all_languages
  catalog.split("\n").drop(1).map{ |line| line.split[-1] }
  # [ bcpl-all_tests_passed, bash_shunit2, clang_assert, gcc_cpputest, ...]
end

def in_catalog?(image)
  all_languages.include?(image)
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def all_cdf_images
  di = `docker images | grep #{$docker_hub_username}`
  # cyberdojofoundation/visual-basic_nunit   latest  eb5f54114fe6 4 months ago 497.4 MB
  # cyberdojofoundation/ruby_mini_test       latest  c7d7733d5f54 4 months ago 793.4 MB
  # cyberdojofoundation/ruby_rspec           latest  ce9425d1690d 4 months ago 411.2 MB
  # ...
  di.split("\n").map{ |line| line.split[0].split('/')[1] }
  # visual-basic_nunit
  # ruby_mini_test
  # ruby_rspec
  # ...
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def images
  pulled = all_cdf_images
  all = catalog.split("\n")
  heading = [ all.shift ]
  languages = all.select do |line|
    image = line.split[-1]
    pulled.include? image
  end
  (heading + languages).join("\n")
end

def languages
  images.split("\n").drop(1).map { |line| line.split[-1] }
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def upgrade
  languages.each { |image| run "docker pull #{$docker_hub_username}/#{image}:latest" }
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def bad_image(image)
  if image.nil?
    puts 'missing IMAGE'
  else
    puts "unknown IMAGE #{image}"
  end
  puts "Try '#{$me} help'"
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def pull(image)
  docker_pull = lambda { |tag| run "docker pull #{$docker_hub_username}/#{tag}:latest" }
  if image == 'all'
    all_languages.each do |language|
      docker_pull.call(language)
    end
  elsif in_catalog?(image)
    docker_pull.call(image)
  else
    bad_image(image)
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def remove(image)
  if languages.include?(image)
    run "docker rmi #{$docker_hub_username}/#{image}"
  elsif all_languages.include?(image)
    puts "IMAGE #{image} is not installed"
    puts "Try '#{$me} help'"
  else
    bad_image(image)
  end
end

#= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

if ARGV.length == 0
  puts 'no command entered'
  puts "Try '#{$me} help'"
  exit
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

options = {}
arg = ARGV[0].to_sym
if [:help, :up, :down, :catalog, :images, :upgrade, :pull, :remove, :backup].include? arg
  options[arg] = true
else
  puts "#{$me}: #{arg} ?"
  puts "Try '#{$me} help"
  exit
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

puts help       if options[:help]
up              if options[:up]
puts catalog    if options[:catalog]
puts images     if options[:images]
upgrade         if options[:upgrade]
pull(ARGV[1])   if options[:pull]
remove(ARGV[1]) if options[:remove]
backup          if options[:backup]
