require 'jenkins_api_client'

module AnacapaJenkinsAPI
  class Job
    attr_reader :job_name
    def initialize(job_name)
      @job_name = job_name
    end

    def rebuild(env=nil) # NOTE: this can throw connection exceptions etc.
      build_no = AnacapaJenkinsAPI.client.job.build(@job_name, env || {}, {
          :build_start_timeout => 30,
          :poll_interval => 1
      })
      get_build(build_no)
    end

    def current_build
      result = AnacapaJenkinsAPI.client.job.get_current_build_number(@job_name)
      return nil if result < 1
      get_build(result)
    end

    def get_build(build_no)
      Build.new(self, build_no)
    end

    def exists?
      AnacapaJenkinsAPI.client.job.exists?(@job_name)
    end

    def destroy!
      AnacapaJenkinsAPI.client.job.delete(@job_name)
    end
  end

end