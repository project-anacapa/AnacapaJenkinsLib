require './job'
require 'jenkins_api_client'

module AnacapaJenkinsAPI
  class Assignment
    attr_reader :git_provider_domain
    attr_reader :course_org
    attr_reader :credentials_id
    attr_reader :credentials_id
    attr_reader :lab_name

    attr_reader :job_grader
    attr_reader :job_instructor

    def initialize(git_provider_domain:, course_org:, credentials_id:, lab_name:)
      @git_provider_domain = git_provider_domain
      @course_org = course_org
      @credentials_id = credentials_id
      @lab_name = lab_name

      @job_instructor = Job.new(assignment_job(@git_provider_domain, @course_org, @lab_name))
      @job_grader = Job.new(grader_job(@git_provider_domain, @course_org, @lab_name))
    end

    def check_jenkins_state
      # checks that the projects exist on jenkins
      if !@job_instructor.exists? || !@job_grader.exists?
        # If one didn't exist, start over from scratch and
        # trigger a rebuild of both the instructor and grader jobs...
        begin
          @job_instructor.destroy!
        rescue
          # ignored
        end
        begin
          @job_grader.destroy!
        rescue
          # ignored
        end

        setup_build = setup_assignment_job.rebuild({
            :git_provider_domain => @git_provider_domain,
            :course_org => @course_org,
            :credentials_id => @credentials_id,
            :lab_name => @lab_name
        })

        setup_build.wait_for_finish

        details = setup_build.details

        raise "An error was encountered while running the grader jobs." \
              "Status: #{details["result"]}" unless details["result"] == "SUCCESS"
        raise "Failed to create the expected jobs." unless !@job_instructor.exists? || !@job_grader.exists?
      end
    end
  end
end