require 'fastlane/action'
require_relative '../helper/xccov_helper'

module Fastlane
  module Actions
    class XccovMergeAction < Action
      def self.run(params)
        cmd = ["xcrun", "xccov", "merge"]
        
        # Add output report path if provided
        cmd << "--outReport" << params[:out_report] if params[:out_report]
        
        # Add output archive path if provided
        cmd << "--outArchive" << params[:out_archive] if params[:out_archive]
        
        # Add all report and archive pairs
        if params[:reports] && params[:archives]
          if params[:reports].length != params[:archives].length
            UI.user_error!("The number of reports and archives must be the same")
          end
          
          params[:reports].each_with_index do |report, index|
            cmd << report
            cmd << params[:archives][index]
          end
        elsif params[:reports]
          # Just add reports if provided without archives
          params[:reports].each { |report| cmd << report }
        end
        
        # Execute command
        return Helper::XccovHelper.run_command(cmd.join(" "))
      end

      def self.description
        "Merge code coverage data using Apple's xccov merge command"
      end

      def self.authors
        ["crazymanish"]
      end

      def self.return_value
        "Returns the output of the xccov merge command"
      end

      def self.details
        "This action allows you to merge multiple .xccovreport and .xccovarchive files into a single coverage report"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :reports,
                                  env_name: "XCCOV_MERGE_REPORTS",
                               description: "Paths to the .xccovreport files to merge",
                                  optional: false,
                                      type: Array,
                              verify_block: proc do |value|
                                              value.each do |path|
                                                UI.user_error!("Report does not exist at path '#{path}'") unless File.exist?(path)
                                              end
                                            end),
          FastlaneCore::ConfigItem.new(key: :archives,
                                  env_name: "XCCOV_MERGE_ARCHIVES",
                               description: "Paths to the .xccovarchive files to merge (should match the number of reports)",
                                  optional: true,
                                      type: Array,
                              verify_block: proc do |value|
                                              value.each do |path|
                                                UI.user_error!("Archive does not exist at path '#{path}'") unless File.exist?(path)
                                              end
                                            end),
          FastlaneCore::ConfigItem.new(key: :out_report,
                                  env_name: "XCCOV_MERGE_OUT_REPORT",
                               description: "Path where the merged .xccovreport will be saved",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :out_archive,
                                  env_name: "XCCOV_MERGE_OUT_ARCHIVE",
                               description: "Path where the merged .xccovarchive will be saved",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xccov_merge(reports: ["report1.xccovreport", "report2.xccovreport"], out_report: "merged.xccovreport")',
          'xccov_merge(
            reports: ["report1.xccovreport", "report2.xccovreport"],
            archives: ["archive1.xccovarchive", "archive2.xccovarchive"],
            out_report: "merged.xccovreport",
            out_archive: "merged.xccovarchive"
          )'
        ]
      end
    end
  end
end