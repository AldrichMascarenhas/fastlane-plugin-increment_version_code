require 'tempfile'
require 'fileutils'

module Fastlane
  module Actions
    class IncrementVersionCodeAction < Action
      def self.run(params)

        version_code = "0"
        new_version_code ||= params[:version_code]
            UI.message("The increment_version_code plugin will use #{new_version_code}")


        gradle_file_path ||= params[:gradle_file_path]
        if gradle_file_path != nil
            UI.message("The increment_version_code plugin will use gradle file at (#{gradle_file_path})!")
            new_version_code = incrementVersion(gradle_file_path, new_version_code)
        else
            app_folder_name ||= params[:app_folder_name]
            UI.message("The get_version_code plugin is looking inside your project folder (#{app_folder_name})!")

            #temp_file = Tempfile.new('fastlaneIncrementVersionCode')
            #foundVersionCode = "false"
            Dir.glob("**/#{app_folder_name}/build.gradle") do |path|
                UI.message(" -> Found a build.gradle file at path: (#{path})!")
                new_version_code = incrementVersion(path, new_version_code)
            end

        end

        if new_version_code == -1
            UI.user_error!("Impossible to find the version code with the specified properties 😭")
        else
            # Store the version name in the shared hash
            Actions.lane_context["VERSION_CODE"]=new_version_code
            UI.success("☝️ Version code has been changed to #{new_version_code}")
        end

        return new_version_code
      end

      def self.incrementVersion(path, newVersion)

            if !File.file?(path)
                UI.message(" -> No file exist at path: (#{path})!")
                return -1
            end
            begin

                oldArr = newVersion.split('.').map{|v| v.to_i}

                newversionMajor = oldArr[0].to_s
                newversionMinor = oldArr[1].to_s
                newversionPatch = oldArr[2].to_s

                foundVersionCodeMajor = "false"
                foundVersionCodeMinor = "false"
                foundVersionCodePatch = "false"

                temp_file = Tempfile.new('fastlaneIncrementVersionCode')

                File.open(path, 'r') do |file|
                    file.each_line do |line|

                        if line.include? "versionMajor" and foundVersionCodeMajor=="false"
                            UI.message(" -> line: (#{line})!")


                          line.replace line.sub(/\d+/, newversionMajor)
                        
                          foundVersionCodeMajor = "true"
                           UI.message(" ->new  line: (#{line})!")


                          
                          temp_file.puts line

                        elsif line.include? "versionMinor" and foundVersionCodeMinor=="false"
                            UI.message(" -> line: (#{line})!")

                          line.replace line.sub(/\d+/, newversionMinor)
                        
                          foundVersionCodeMinor = "true"

                           UI.message(" ->new  line: (#{line})!")

                          
                          temp_file.puts line

                        elsif line.include? "versionPatch" and foundVersionCodePatch=="false"
                              UI.message(" -> line: (#{line})!")


                          line.replace line.sub(/\d+/, newversionPatch)
                        

                          foundVersionCodePatch = "true"
                      
                          UI.message(" ->new  line: (#{line})!")

    
                          temp_file.puts line
                            
                        else
                          temp_file.puts line

                     end
                end
                file.close
              end
              temp_file.rewind
              temp_file.close
              FileUtils.mv(temp_file.path, path)
              temp_file.unlink
            end
            if foundVersionCodeMajor == "true" && foundVersionCodeMinor == "true" && foundVersionCodePatch
                return newVersion
            end
            return -1
      end

      def self.description
        "Increment the version code of your android project."
      end

      def self.authors
        ["Jems"]
      end

      def self.available_options
          [
             FastlaneCore::ConfigItem.new(key: :gradle_file_path,
                                     env_name: "INCREMENTVERSIONCODE_GRADLE_FILE_PATH",
                                  description: "The relative path to the gradle file containing the version code parameter (default:app/build.gradle)",
                                     optional: true,
                                         type: String,
                                default_value: nil),
              FastlaneCore::ConfigItem.new(key: :version_code,
                                      env_name: "INCREMENTVERSIONCODE_VERSION_CODE",
                                   description: "Change to a specific version (optional)",
                                      optional: true,
                                          type: String,
                                 default_value: "fail")
          ]
      end

      def self.output
        [
          ['VERSION_CODE', 'The new version code of the project']
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
