require 'jenkins_api_client'

module AnacapaJenkinsAPI
  class Assignment
    attr_reader :callback_url
    attr_reader :git_provider_domain
    attr_reader :course_org
    attr_reader :credentials_id
    attr_reader :lab_name

    attr_reader :job_grader
    attr_reader :job_instructor

    def initialize(callback_url:, git_provider_domain:, course_org:, credentials_id:, lab_name:)
      @callback_url = callback_url
      @git_provider_domain = git_provider_domain
      @course_org = course_org
      @credentials_id = credentials_id
      @lab_name = lab_name

      @job_instructor = JenkinsJob.new("AnacapaGrader #{git_provider_domain} #{course_org} assignment-#{lab_name}")
      @job_grader = JenkinsJob.new("AnacapaGrader #{git_provider_domain} #{course_org} grader-#{lab_name}")
    end

    def check_jenkins_state
      # checks whether the projects exist on jenkins
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
            :callback_url => @callback_url,
            :git_provider_domain => @git_provider_domain,
            :course_org => @course_org,
            :credentials_id => @credentials_id,
            :lab_name => @lab_name
        })

        setup_build.wait_for_finish

        details = setup_build.details

        # if not job success
        raise "An error was encountered while running the grader jobs." \
              "Status: #{details["result"]}" unless details["result"] == "SUCCESS"
        # if one of the jobs still don't exist
        raise "Failed to create the expected jobs." unless !@job_instructor.exists? || !@job_grader.exists?
      end
    end
  end
end