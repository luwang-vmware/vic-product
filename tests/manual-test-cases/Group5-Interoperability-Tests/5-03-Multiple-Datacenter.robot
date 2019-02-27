# Copyright 2018 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

*** Settings ***
Documentation  Test 5-03 - Multiple Datacenters
Resource  ../../resources/Util.robot
Suite Setup  Nimbus Suite Setup  Multiple Datacenter Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Pod Cleanup  ${nimbus_pod}  ${testbedname}
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Collect Appliance and VCH Logs  ${VCH-NAME}
Test Timeout  90 minutes

*** Keywords ***
Multiple Datacenter Setup
# set up nimbus test bed and env variables
    [Timeout]    60 minutes
    ${name}=  Evaluate  'vic-multi-dc-' + str(random.randint(1000,9999))  modules=random
    Log To Console  Create a new simple vc cluster with spec vic-multi-dc.rb...
    ${out}=  Deploy Nimbus Testbed  spec=vic-multi-dc.rb  args=--noSupportBundles --plugin testng --vcvaBuild "${VC_VERSION}" --esxBuild "${ESX_VERSION}" --testbedName vic-multi-dc --runName ${name}
    Log  ${out}
    Log To Console  Finished creating cluster ${name}

    ${out}=  Execute Command  ${NIMBUS_LOCATION_FULL} USER=%{NIMBUS_PERSONAL_USER} nimbus-ctl ip %{NIMBUS_PERSONAL_USER}-${name}.vc.0 | grep %{NIMBUS_PERSONAL_USER}-${name}.vc.0
    ${vc_ip}=  Fetch From Right  ${out}  ${SPACE}
    Log  ${vc_ip}

    ${pod}=  Fetch Pod  ${name}
    Log  ${pod}
    # set nimbus variable
    Set Suite Variable  ${nimbus_pod}  ${pod}
    Set Suite Variable  ${testbedname}  ${name}

    # set test variables
    Set Environment Variable  TEST_URL  ${vc_ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  /dc1/host/cls1
    # Make sure we use correct datastore
    Set Environment Variable  TEST_DATASTORE  sharedVmfs-0
 
    # set VC variables
    Set Test VC Variables
    # set VCH variables
    Set Environment Variable  DRONE_BUILD_NUMBER  0
    Set Environment Variable  VCH_TIMEOUT  20m0s
    # set docker variables
    # not using dind but host dockerd for these nightly tests
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER}  docker
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER_ENDPOINT}  unix:///var/run/docker.sock
    # set harbor variables
    Set Global Variable  ${DEFAULT_HARBOR_PROJECT}  default-project
    # govc env variables
    Set Environment Variable  GOVC_URL  %{TEST_URL}
    Set Environment Variable  GOVC_USERNAME  %{TEST_USERNAME}
    Set Environment Variable  GOVC_PASSWORD  %{TEST_PASSWORD}
    Set Environment Variable  GOVC_INSECURE  1
    # check VC
    Check VCenter

*** Test Cases ***
Test
    Deploy OVA And Install UI Plugin And Run Regression Tests  5-03-TEST  vic-*.ova  %{TEST_DATASTORE}  %{BRIDGE_NETWORK}  %{PUBLIC_NETWORK}  %{TEST_USERNAME}  %{TEST_PASSWORD}
