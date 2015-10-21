# Change Log

## [v0.15.1](https://github.com/chef/chef-provisioning-fog/tree/v0.15.1) (2015-10-21)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.15.0...v0.15.1)

**Fixed bugs:**

- \[openstack\] timeout calculation [\#106](https://github.com/chef/chef-provisioning-fog/issues/106)
- Fix for \#106 [\#133](https://github.com/chef/chef-provisioning-fog/pull/133) ([jjasghar](https://github.com/jjasghar))

**Closed issues:**

- Simple example fails with :transport\_options required \[openstack\] [\#127](https://github.com/chef/chef-provisioning-fog/issues/127)
- Rackspace - support for RackConnect [\#124](https://github.com/chef/chef-provisioning-fog/issues/124)
- fails to authenticate \(chef server 10.18.2\) [\#26](https://github.com/chef/chef-provisioning-fog/issues/26)

**Merged pull requests:**

- Fixed up examples. [\#134](https://github.com/chef/chef-provisioning-fog/pull/134) ([jjasghar](https://github.com/jjasghar))
- Add gemspec files to allow bundler to run from the gem [\#132](https://github.com/chef/chef-provisioning-fog/pull/132) ([ksubrama](https://github.com/ksubrama))
- Add a Rackspace example with code samples/links [\#131](https://github.com/chef/chef-provisioning-fog/pull/131) ([martinb3](https://github.com/martinb3))
- Adding to the README.md [\#126](https://github.com/chef/chef-provisioning-fog/pull/126) ([jjasghar](https://github.com/jjasghar))
- All docs point to :bootstrap\_options [\#125](https://github.com/chef/chef-provisioning-fog/pull/125) ([jjasghar](https://github.com/jjasghar))

## [v0.15.0](https://github.com/chef/chef-provisioning-fog/tree/v0.15.0) (2015-09-16)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.14.0...v0.15.0)

**Fixed bugs:**

- Solve NoMethodError for fog providers that do not provide the 'addresses' method to the 'server' object [\#93](https://github.com/chef/chef-provisioning-fog/pull/93) ([SIGUSR2](https://github.com/SIGUSR2))

**Merged pull requests:**

- Adding a CONTRIBUTING document  [\#121](https://github.com/chef/chef-provisioning-fog/pull/121) ([tyler-ball](https://github.com/tyler-ball))
- google-provider: Adds ability to specify default disk size [\#103](https://github.com/chef/chef-provisioning-fog/pull/103) ([kri5](https://github.com/kri5))
- Added XenServer support [\#99](https://github.com/chef/chef-provisioning-fog/pull/99) ([kongslund](https://github.com/kongslund))
- Support for "no\_network" by introduction of ssh\_address\_locations option [\#96](https://github.com/chef/chef-provisioning-fog/pull/96) ([bdangit](https://github.com/bdangit))

## [v0.14.0](https://github.com/chef/chef-provisioning-fog/tree/v0.14.0) (2015-08-12)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.13.2...v0.14.0)

**Fixed bugs:**

- Driver 'location' hash issue [\#116](https://github.com/chef/chef-provisioning-fog/issues/116)
- Better message about inability to connect [\#62](https://github.com/chef/chef-provisioning-fog/issues/62)
- Change 'location' hash to 'reference', fixes \#116 [\#117](https://github.com/chef/chef-provisioning-fog/pull/117) ([hulu1522](https://github.com/hulu1522))
- google-provider: Do not override bootstrap\_options if set [\#102](https://github.com/chef/chef-provisioning-fog/pull/102) ([kri5](https://github.com/kri5))

**Closed issues:**

- Add support for Google Cloud Engine \(GCE\) [\#75](https://github.com/chef/chef-provisioning-fog/issues/75)

**Merged pull requests:**

- Fog, vCloud Air, OpenStack, DigitalOcean, edit re: chef-metal [\#115](https://github.com/chef/chef-provisioning-fog/pull/115) ([jamescott](https://github.com/jamescott))
- Initial .travis.yml. [\#112](https://github.com/chef/chef-provisioning-fog/pull/112) ([randomcamel](https://github.com/randomcamel))
- Add openstack image support [\#110](https://github.com/chef/chef-provisioning-fog/pull/110) ([hh](https://github.com/hh))
- Windows support working [\#107](https://github.com/chef/chef-provisioning-fog/pull/107) ([hh](https://github.com/hh))
- Implement Retryable to fix RequestLimitExceeded error from Fog::Compute::AWS::Error [\#101](https://github.com/chef/chef-provisioning-fog/pull/101) ([irvingpop](https://github.com/irvingpop))
- Adds servers\_for method to google provider [\#98](https://github.com/chef/chef-provisioning-fog/pull/98) ([kri5](https://github.com/kri5))
- Adds a provider to support Google cloud [\#97](https://github.com/chef/chef-provisioning-fog/pull/97) ([kri5](https://github.com/kri5))

## [v0.13.2](https://github.com/chef/chef-provisioning-fog/tree/v0.13.2) (2015-04-02)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.13.1...v0.13.2)

**Closed issues:**

- AWS EC2 Windows Server 2012 R2 User Data Error [\#84](https://github.com/chef/chef-provisioning-fog/issues/84)

## [v0.13.1](https://github.com/chef/chef-provisioning-fog/tree/v0.13.1) (2015-03-04)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.13...v0.13.1)

**Fixed bugs:**

- tugboatrc seems to override with\_machine\_options in bad ways [\#56](https://github.com/chef/chef-provisioning-fog/issues/56)
- chef-meta-fog w/ digital ocean errors with "NoMethodError: undefined method `parallel\_do' for \#\<Chef::ChefFS::Parallelizer:0xxxx\>" [\#32](https://github.com/chef/chef-provisioning-fog/issues/32)

**Closed issues:**

- Uninitialized constant ActionFailed [\#76](https://github.com/chef/chef-provisioning-fog/issues/76)

**Merged pull requests:**

- Updating for wrong method error [\#88](https://github.com/chef/chef-provisioning-fog/pull/88) ([tyler-ball](https://github.com/tyler-ball))
- Fix DigitalOcean defaults \(fixes \#56\) [\#87](https://github.com/chef/chef-provisioning-fog/pull/87) ([jkeiser](https://github.com/jkeiser))

## [v0.13](https://github.com/chef/chef-provisioning-fog/tree/v0.13) (2015-02-26)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.12...v0.13)

**Fixed bugs:**

- Providers::AWS calls nonexistent Cheffish::MergedConfig\#delete [\#57](https://github.com/chef/chef-provisioning-fog/issues/57)
- attach\_ip\_from\_pool and attach\_ip updates in fog\_driver.rb [\#48](https://github.com/chef/chef-provisioning-fog/issues/48)

**Closed issues:**

- Unable to set convergence\_options with AWS driver [\#78](https://github.com/chef/chef-provisioning-fog/issues/78)
- Attaching floating IP addresses [\#77](https://github.com/chef/chef-provisioning-fog/issues/77)
- Support loading AWS credentials from ~/.aws/credentials [\#41](https://github.com/chef/chef-provisioning-fog/issues/41)

**Merged pull requests:**

- Handle convergence\_options with MergedConfig. [\#85](https://github.com/chef/chef-provisioning-fog/pull/85) ([msonnabaum](https://github.com/msonnabaum))

## [v0.12](https://github.com/chef/chef-provisioning-fog/tree/v0.12) (2015-01-27)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.11...v0.12)

**Closed issues:**

- IAM roles for provisioning unsupported [\#80](https://github.com/chef/chef-provisioning-fog/issues/80)
- Add winrm support to fog driver [\#28](https://github.com/chef/chef-provisioning-fog/issues/28)

**Merged pull requests:**

- Added IAM role support for provisioner hosts. [\#81](https://github.com/chef/chef-provisioning-fog/pull/81) ([justindossey](https://github.com/justindossey))

## [v0.11](https://github.com/chef/chef-provisioning-fog/tree/v0.11) (2014-11-05)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.10...v0.11)

**Merged pull requests:**

- Work with Chef 12 load\_prior\_resource [\#68](https://github.com/chef/chef-provisioning-fog/pull/68) ([jkeiser](https://github.com/jkeiser))
- WinRM support for AWS [\#67](https://github.com/chef/chef-provisioning-fog/pull/67) ([johnewart](https://github.com/johnewart))

## [v0.10](https://github.com/chef/chef-provisioning-fog/tree/v0.10) (2014-10-31)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.9...v0.10)

**Closed issues:**

- AWS\#convergence\_strategy\_for can be called with machine\_options\[:convergence\_options\] == nil [\#61](https://github.com/chef/chef-provisioning-fog/issues/61)
- Bug calling find\_aws\_profile\_for\_account\_id with iam\_endpoint and not default\_iam\_endpoint [\#60](https://github.com/chef/chef-provisioning-fog/issues/60)
- Not using AWS\_DEFAULT\_REGION environment variable [\#54](https://github.com/chef/chef-provisioning-fog/issues/54)
- undefined method `join' for Chef::Util::PathHelper:Class [\#50](https://github.com/chef/chef-provisioning-fog/issues/50)

**Merged pull requests:**

- Rename to chef-provisioning [\#65](https://github.com/chef/chef-provisioning-fog/pull/65) ([jkeiser](https://github.com/jkeiser))
- Fix typo in digitalocean provider [\#64](https://github.com/chef/chef-provisioning-fog/pull/64) ([nomadium](https://github.com/nomadium))
- Fix `machine\_options\[:convergence\_options\]` to always have a hash value and not be nil [\#58](https://github.com/chef/chef-provisioning-fog/pull/58) ([rberger](https://github.com/rberger))
- Try some different REGION env variables [\#55](https://github.com/chef/chef-provisioning-fog/pull/55) ([nathenharvey](https://github.com/nathenharvey))

## [v0.9](https://github.com/chef/chef-provisioning-fog/tree/v0.9) (2014-09-05)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.8...v0.9)

**Fixed bugs:**

- Be nicer when machine\_options\[:bootstrap\_options\] doesn't exist [\#38](https://github.com/chef/chef-provisioning-fog/issues/38)

**Closed issues:**

- Default fog instance [\#45](https://github.com/chef/chef-provisioning-fog/issues/45)
- add public ip / dns to node data \(ec2\) [\#39](https://github.com/chef/chef-provisioning-fog/issues/39)

**Merged pull requests:**

- Fix crash when profile not specified [\#49](https://github.com/chef/chef-provisioning-fog/pull/49) ([jkeiser](https://github.com/jkeiser))
- Set a sane default EC2 AMI if not provided one [\#46](https://github.com/chef/chef-provisioning-fog/pull/46) ([johnewart](https://github.com/johnewart))

## [v0.8](https://github.com/chef/chef-provisioning-fog/tree/v0.8) (2014-08-18)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.7.1...v0.8)

**Merged pull requests:**

- add ohai ec2 hints by default to aws provider [\#40](https://github.com/chef/chef-provisioning-fog/pull/40) ([patrick-wright](https://github.com/patrick-wright))
- Adding initial support for Joyent Public Cloud. [\#37](https://github.com/chef/chef-provisioning-fog/pull/37) ([potatosalad](https://github.com/potatosalad))
- Add AWS support for images [\#36](https://github.com/chef/chef-provisioning-fog/pull/36) ([jkeiser](https://github.com/jkeiser))
- Allow EC2/IAM endpoint configuration [\#34](https://github.com/chef/chef-provisioning-fog/pull/34) ([viglesiasce](https://github.com/viglesiasce))
- Fixed method call on tag arrays. [\#33](https://github.com/chef/chef-provisioning-fog/pull/33) ([msonnabaum](https://github.com/msonnabaum))

## [v0.7.1](https://github.com/chef/chef-provisioning-fog/tree/v0.7.1) (2014-07-15)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.7...v0.7.1)

**Closed issues:**

- uninitialized class variable @@use\_pkcs8 [\#31](https://github.com/chef/chef-provisioning-fog/issues/31)

## [v0.7](https://github.com/chef/chef-provisioning-fog/tree/v0.7) (2014-07-08)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.6.1...v0.7)

**Closed issues:**

- Add interface for FogProvider [\#11](https://github.com/chef/chef-provisioning-fog/issues/11)

**Merged pull requests:**

- fix default timeout in comments [\#30](https://github.com/chef/chef-provisioning-fog/pull/30) ([dwradcliffe](https://github.com/dwradcliffe))
- Create AWS instances in parallel with one request [\#29](https://github.com/chef/chef-provisioning-fog/pull/29) ([jkeiser](https://github.com/jkeiser))
- Return an empty string for CloudStack \#creator [\#27](https://github.com/chef/chef-provisioning-fog/pull/27) ([rarenerd](https://github.com/rarenerd))

## [v0.6.1](https://github.com/chef/chef-provisioning-fog/tree/v0.6.1) (2014-06-18)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.6...v0.6.1)

## [v0.6](https://github.com/chef/chef-provisioning-fog/tree/v0.6) (2014-06-18)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.4...v0.6)

**Merged pull requests:**

- Split drivers into individual classes [\#25](https://github.com/chef/chef-provisioning-fog/pull/25) ([thommay](https://github.com/thommay))
- Use unix timestamps rather than strings [\#24](https://github.com/chef/chef-provisioning-fog/pull/24) ([thommay](https://github.com/thommay))

## [v0.5.4](https://github.com/chef/chef-provisioning-fog/tree/v0.5.4) (2014-06-10)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.3...v0.5.4)

**Merged pull requests:**

- use ssh paths from tugboat file [\#23](https://github.com/chef/chef-provisioning-fog/pull/23) ([lamont-granquist](https://github.com/lamont-granquist))

## [v0.5.3](https://github.com/chef/chef-provisioning-fog/tree/v0.5.3) (2014-06-05)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.2...v0.5.3)

**Merged pull requests:**

- only compare the relevant bits of the ssh key fingerprint [\#22](https://github.com/chef/chef-provisioning-fog/pull/22) ([thommay](https://github.com/thommay))

## [v0.5.2](https://github.com/chef/chef-provisioning-fog/tree/v0.5.2) (2014-06-04)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.1...v0.5.2)

## [v0.5.1](https://github.com/chef/chef-provisioning-fog/tree/v0.5.1) (2014-06-04)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5...v0.5.1)

**Merged pull requests:**

- Load credentials from openstack correctly, too [\#21](https://github.com/chef/chef-provisioning-fog/pull/21) ([thommay](https://github.com/thommay))

## [v0.5](https://github.com/chef/chef-provisioning-fog/tree/v0.5) (2014-06-04)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.beta.6...v0.5)

**Merged pull requests:**

- Don't used the InstallCached by default, instead use InstallSh  [\#20](https://github.com/chef/chef-provisioning-fog/pull/20) ([irvingpop](https://github.com/irvingpop))
- fix up rackspace support [\#19](https://github.com/chef/chef-provisioning-fog/pull/19) ([thommay](https://github.com/thommay))

## [v0.5.beta.6](https://github.com/chef/chef-provisioning-fog/tree/v0.5.beta.6) (2014-06-03)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.beta.5...v0.5.beta.6)

## [v0.5.beta.5](https://github.com/chef/chef-provisioning-fog/tree/v0.5.beta.5) (2014-06-03)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.beta.4...v0.5.beta.5)

## [v0.5.beta.4](https://github.com/chef/chef-provisioning-fog/tree/v0.5.beta.4) (2014-06-03)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.beta.3...v0.5.beta.4)

## [v0.5.beta.3](https://github.com/chef/chef-provisioning-fog/tree/v0.5.beta.3) (2014-05-31)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.beta.2...v0.5.beta.3)

**Merged pull requests:**

- Rackspace Public Cloud support [\#18](https://github.com/chef/chef-provisioning-fog/pull/18) ([hhoover](https://github.com/hhoover))
- Use strings instead of symbols for machine\_spec.location map [\#17](https://github.com/chef/chef-provisioning-fog/pull/17) ([marcusn](https://github.com/marcusn))
- Fixed sym vs string key for ssh gateway [\#14](https://github.com/chef/chef-provisioning-fog/pull/14) ([marcusn](https://github.com/marcusn))
- Fixed typo machine vs machine\_spec [\#13](https://github.com/chef/chef-provisioning-fog/pull/13) ([marcusn](https://github.com/marcusn))
- Added support for CloudStack [\#12](https://github.com/chef/chef-provisioning-fog/pull/12) ([marcusn](https://github.com/marcusn))

## [v0.5.beta.2](https://github.com/chef/chef-provisioning-fog/tree/v0.5.beta.2) (2014-05-28)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.5.beta...v0.5.beta.2)

## [v0.5.beta](https://github.com/chef/chef-provisioning-fog/tree/v0.5.beta) (2014-05-23)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.4...v0.5.beta)

**Merged pull requests:**

- Instances spin up with "default" name [\#10](https://github.com/chef/chef-provisioning-fog/pull/10) ([mikesplain](https://github.com/mikesplain))
- Fix for name issue Chef-Metal \#52 [\#9](https://github.com/chef/chef-provisioning-fog/pull/9) ([mikesplain](https://github.com/mikesplain))
- Add ssh\_gateway as an option to for SSH Transport [\#8](https://github.com/chef/chef-provisioning-fog/pull/8) ([JonathanSerafini](https://github.com/JonathanSerafini))

## [v0.4](https://github.com/chef/chef-provisioning-fog/tree/v0.4) (2014-05-01)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.3.1...v0.4)

**Merged pull requests:**

- Support PKCS\#8 SHA1 fingerprints used by AWS for generated keys. [\#7](https://github.com/chef/chef-provisioning-fog/pull/7) ([andrewdotn](https://github.com/andrewdotn))
- fix typo and remove bad line [\#6](https://github.com/chef/chef-provisioning-fog/pull/6) ([ohlol](https://github.com/ohlol))
- bug fixes [\#5](https://github.com/chef/chef-provisioning-fog/pull/5) ([wilreichert](https://github.com/wilreichert))
- fix attach\_ip [\#4](https://github.com/chef/chef-provisioning-fog/pull/4) ([ohlol](https://github.com/ohlol))
- Remove empty fog.rb file [\#3](https://github.com/chef/chef-provisioning-fog/pull/3) ([RoboticCheese](https://github.com/RoboticCheese))
- select creator based on provider [\#2](https://github.com/chef/chef-provisioning-fog/pull/2) ([wilreichert](https://github.com/wilreichert))

## [v0.3.1](https://github.com/chef/chef-provisioning-fog/tree/v0.3.1) (2014-04-14)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.3...v0.3.1)

## [v0.3](https://github.com/chef/chef-provisioning-fog/tree/v0.3) (2014-04-13)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.2.1...v0.3)

## [v0.2.1](https://github.com/chef/chef-provisioning-fog/tree/v0.2.1) (2014-04-11)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.2...v0.2.1)

## [v0.2](https://github.com/chef/chef-provisioning-fog/tree/v0.2) (2014-04-11)
[Full Changelog](https://github.com/chef/chef-provisioning-fog/compare/v0.1...v0.2)

**Closed issues:**

- Gem homepage gives a 404 [\#1](https://github.com/chef/chef-provisioning-fog/issues/1)

## [v0.1](https://github.com/chef/chef-provisioning-fog/tree/v0.1) (2014-04-04)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
