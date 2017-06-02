# AnacapaJenkinsAPI

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/anacapa_jenkins_api`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'anacapa_jenkins_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install anacapa_jenkins_api

## Usage

### API
The format of the config file is
```YAML
server_url: http://ci.domain.com:80
username: admin
password: <access token>
```

The Module exposes the following methods/classes
```ruby
AnacapaJenkinsAPI.configure(YAML.load('./credentials.yml')) # to configure the connection to the Jenkins instance

AnacapaJenkinsAPI.client # gets direct access to the Jenkins API Client, should be needed externally

AnacapaJenkinsAPI.Build.new(instance of job, buildNo) # returns a wrapper around the build with the given buildId

Build.details(force: true) # fetches the details for a build. Force determines wether to refetch them or use the cached result from the last call to details

Build.artifacts # makes a request to the jenkins server returning the list of build artifacts

Build.downloadArtifact(artifactObj, baseUrl: nil) # takes an artifact object from the Build.artifacts call and downloads that artifact. baseUrl is automatically computed from cached build details. It can optionally be provided but is not necessary.

Build.waitForBuildToFinish() # blocks thread and polls jenkins until the build finishes (or fails)


AnacapaJenkinsAPI.Job.new(jobName) # constructs a new job wrapper with the name provided

Job.rebuild(env=nil) # rebuilds the job (optionally with the env provided)

Job.currentBuild # returns a build that is the most recent build of the job. Nil if no builds.

Job.getBuild(buildNo) # returns the build with the given build no. Nil if not found.

Job.exists? # checks that the job actually exists on the Jenkins installation

Job.destroy! # destroys the job on the server

AnacapaJenkinsAPI.Assignment.new(
  :gitProviderDomain => "github.com",
  :courseOrg => "ucsb-cs-test-org-1", # test
  :credentialsId => "github.com-gareth-machine-user",
  :labName => "lab00"
)

Assignment.checkJenkinsState # makes sure that the proper jobs for the assignment exist on Jenkins.
```


### Jenkins Configuration
 - _TODO: move this to a more appropriate location_
 - Plugins
    - install Job DSL
    - install Rebuilder
    - install Copy Artifact
    - install Environment Injector Plugin
 - Manage Jenkins -> Configure System -> Click add Global Pipeline Library
    - Add https://github.com/garethgeorge/anacapa-jenkins-lib to your jenkins libraries
    - default version: master
    - retrieval method: github
    - load implicitly: true
 - Additional Steps for Development
    - Go to Security -> Enable Script Security for Job DSL
       - Uncheck the setting to avoid annoying confirmation dialogs
    - Go to Manage Nodes and edit the settings for 'master' and add the 'submit' label
        - this is because in production you would add worker slaves with ssh credentials and the 'submit' label but this is entirely unnecessary for development.
 - Restart Jenkins and you should be good to go!

### Jenkins Jobs Setup
 - Create Job -> Free Style Project
    - name: anacapa-jenkins-lib (note this job will bootstrap the construction of other jobs)
    - turn on Build Enviornment -> 'delete workspace before build' setting in the job setup
    - build -> add build step -> Process Job DSLs
        - look on file system
        - DLS Scripts: jobs/standaloneSetupAssignment.groovy
    - save changes!
    - run the job
        - you should see a new job 'AnacapaGrader-setupAssignment'


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/anacapa_jenkins_api.
