namespace: Integrations.demo.aos.sub_flows
flow:
  name: deploy_wars
  inputs:
    - tomcat_host: 10.0.46.45
    - account_service_host: 10.0.46.45
    - db_host: 10.0.46.45
    - username: root
    - password: admin@123
    - url: "${get_sp('war_repo_root_url')}"
  workflow:
    - deploy_account_service:
        do:
          Integrations.demo.aos.sub_flows.initialize_artifact:
            - host: '${account_service_host}'
            - username: '${username}'
            - password: '${password}'
            - script_url: 'http://vmdocker.hcm.demo.local:36980/job/AOS-repo/ws/deploy_wars.sh'
            - artifact_url: "${url+'accountservice/target/accountservice.war'}"
            - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host}"
        navigate:
          - SUCCESS: deploy_tm_wars
          - FAILURE: on_failure
    - deploy_tm_wars:
        loop:
          for: "war in 'catalog','MasterCredit','order','ROOT','ShipEx','SafePay'"
          do:
            Integrations.demo.aos.sub_flows.initialize_artifact:
              - host: '${tomcat_host}'
              - username: '${username}'
              - password: '${password}'
              - artifact_url: "${url+war.lower()+'/target/'+war+'.war'}"
              - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host}"
          break:
            - FAILURE
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      deploy_account_service:
        x: 159
        y: 109
      deploy_tm_wars:
        x: 413
        y: 132
        navigate:
          545c9274-9ee1-74d8-497f-f8477a20b475:
            targetId: 57497fa8-11eb-db3c-74cd-88c625f849bb
            port: SUCCESS
    results:
      SUCCESS:
        57497fa8-11eb-db3c-74cd-88c625f849bb:
          x: 672
          y: 137
