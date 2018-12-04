namespace: Integrations.demo.aos.tools
flow:
  name: delete_file
  inputs:
    - host: 10.0.46.45
    - username: root
    - password: admin@123
    - filename: install_java.sh
  workflow:
    - ssh_command:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && rm -f '+filename}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      ssh_command:
        x: 137
        y: 125
        navigate:
          e47472d7-7be6-f741-f732-222d7765696f:
            targetId: 329304ed-8437-08ff-0e41-315e21aeaf4d
            port: SUCCESS
    results:
      SUCCESS:
        329304ed-8437-08ff-0e41-315e21aeaf4d:
          x: 507
          y: 178
