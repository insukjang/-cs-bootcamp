namespace: Integrations.demo.aos.sub_flows
flow:
  name: initialize_artifact
  inputs:
    - host: 10.0.46.45
    - username: root
    - password: admin@123
    - script_url: 'http://vmdocker.hcm.demo.local:36980/job/AOS-repo/ws/install_java.sh'
    - artifact_url:
        required: false
    - parameters:
        required: false
  workflow:
    - is_artifact_given:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${artifact_url}'
        navigate:
          - SUCCESS: copy_script
          - FAILURE: copy_artifact
    - copy_artifact:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
        publish:
          - artifact_name: '${filename}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: copy_script
    - copy_script:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
        publish:
          - script_name: '${filename}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: execute_command
    - delete_script:
        do:
          Integrations.demo.aos.tools.delete_file:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
            - filename: '${script_name}'
        navigate:
          - SUCCESS: has_failed
          - FAILURE: on_failure
    - execute_command:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && chmod 755 '+script_name+' && sh '+script_name+' '+get('artifact_name', '')+' '+get('parameters', '')+' > '+script_name+'.log'}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        publish:
          - command_return_code
        navigate:
          - SUCCESS: delete_script
          - FAILURE: delete_script
    - has_failed:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: "${str(command_return_code == '0')}"
        navigate:
          - 'TRUE': SUCCESS
          - 'FALSE': FAILURE
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      execute_command:
        x: 189
        y: 373
      is_artifact_given:
        x: 278
        y: 23
      copy_artifact:
        x: 103
        y: 199
      copy_script:
        x: 488
        y: 175
      delete_script:
        x: 399
        y: 371
      has_failed:
        x: 585
        y: 328
        navigate:
          46d2b739-f5bf-3d23-7062-7f86e5b4d138:
            targetId: 2625d09c-4ee7-c6ee-e03a-10d1d98f9d19
            port: 'FALSE'
          773a769a-c985-e812-d936-858d1f27b28f:
            targetId: a2d1ec71-2a6a-b928-d3c5-db2ff8c9b787
            port: 'TRUE'
    results:
      SUCCESS:
        a2d1ec71-2a6a-b928-d3c5-db2ff8c9b787:
          x: 696
          y: 324
      FAILURE:
        2625d09c-4ee7-c6ee-e03a-10d1d98f9d19:
          x: 678
          y: 463
