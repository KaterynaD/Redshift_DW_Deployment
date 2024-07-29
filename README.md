This project demonstrates how I built CI/CD pipeline to handle build, test and deploy Redshift schema changes cycle when a new commit gets into version control.
This diagram illustrates the solution architecture. I use GitHub or AWS CodeCommit to store the code, AWS CodeBuild to run the build process and test environment, and AWS CodePipeline to orchestrate the overall deployment, from source, to test and then, production.
AWS Secret Manager is used to provide Redshift Cluster connection information needed in the database migration and tests.

![image](https://github.com/user-attachments/assets/c1ee6863-9170-4824-bcc2-a5bb4fb9497c)

 
Test environment can be completely empty or partially populated separate Redshift Cluster, database or just a schema. Depending on how big your test data is, it may add additional time and cost for your entire process. A separate test schema is used for testing in the published scenario to keep cost low.

Deploy the CloudFormation template using one of the following files:

a.	One_RedshiftCluster_CodeCommit_cloudformation_template.yml uses AWS CodeCommit GitHub as the Source of the build.

b.	One_RedshiftCluster_GitHub_cloudformation_template.yml uses GitHub as the Source of the build.

The template creates a Redshift Cluster, VPN, CodePipeline, CodeCommit, CodeBuild (using just created VPN and Subnet), Secret Manager and an S3 bucket for test data if needed. A few more S3 buckets are created automatically as a part of CloudFormation and CodePipeline processes. (The buckets must be empty in order to successfully delete CloudFormation stack!)
There are also few AWS Roles are created, so you need to click the check box to acknowledge AWS CloudFormation might create IAM resources.
 
![image](https://github.com/user-attachments/assets/cf635f47-5bd5-4f97-96fe-1d00b1eb8456)

GitHub CloudFormation template creates a connection to GitHub but it’s in a pending state and it must be activated first manually.
Here is the link to the connection in us-west-2 region:
https://us-west-2.console.aws.amazon.com/codesuite/settings/connections?region=us-west-2
 
![image](https://github.com/user-attachments/assets/200bf144-40ab-4882-a2c7-6b96ff634b23)

Before you can push your code into CodeCommit repo, you need to set up Git credentials. 
See details in https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-gc.html

git remote add codecommit https://git-codecommit.us-west-2.amazonaws.com/v1/repos/dw-redshift-devops-repo

git push codecommit main

(or git push codecommit HEAD:main)

CodePipeline first automatic run always fails because of the pending connection to GitHub or empty CodeCommit repo. 
It can be re-run with “Release change” button after the GitHub connection activation.
 
![image](https://github.com/user-attachments/assets/6468fa33-9a4f-4b24-8ed0-e968a9ca9948)

After you push the code to GitHub or CodeCommit repository, this triggers the pipeline to deploy the code into both the test and prod environments. You can monitor the progress on the CodePipeline console.

![image](https://github.com/user-attachments/assets/4e3874ab-18b8-4eda-9672-a80a5fc97524)

CodeBuild runs the build process and test using Maven:

•	Build – During the build process, Maven uses FlyWay.

  o	FlyWay created if not exist a control table in the default schema (see pom.xml) to track the current version of the schema and what needs to be run to bring it up to the version in your repository. Files check sum is used along with the name to determine if it was applied.
  
  o	V* files are used to deploy new versions and U* file to undo (not available in community edition FlyWay )
  
  o	Goal in pom.xml file should be edited to UNDO if there is a need to rollback the change.
  ![image](https://github.com/user-attachments/assets/f8bff15f-b0d0-4381-bc8d-e680b1f3d9dc)

  o	beforeMigrate.sql is used to set up a production environment (production schemas and tables used in testing) in this toy project which is supposed to exist in a production system.

 
•	Test – Maven runs Junit tests against the test environment. It may involve loading test data from a special S3 bucket created. The results of the unit tests are published into the CodeBuild test reports.

The difference between Test and Prod CodeBuild runs are in the actual commands. They can be found in buildspec_test.yml and buildspec-prod.yml. During the creation of Codebuild project I specify what buildspec to use.

Test environment:

mvn -f pom_test.xml clean test

Prod environment:

mvn -f pom_prod.xml clean process-resources


There are also differences in maven pom_test.xml and pom_prod.xml to point FlyWay to specific schemas in each environment.

Test environment:

                  <configuration>
                    <defaultSchema>reporting_test</defaultSchema>
                    <placeholders>
                        <deployment_schema>reporting_test</deployment_schema>
                    </placeholders>
                </configuration>
  
Prod environment:

                <configuration>
                    <defaultSchema>public</defaultSchema>
                    <placeholders>
                        <deployment_schema>reporting</deployment_schema>
                    </placeholders>
                </configuration>



No tests are run in Prod environment assuming exactly the same code is deployed.
If the test fails the process does not move to prod deployment stage.
 
Test reports:
 
![image](https://github.com/user-attachments/assets/7684686e-f243-4279-9ed5-acef3d20d716)

 
![image](https://github.com/user-attachments/assets/8919f4f6-0fbc-425e-9f38-e29093181a59)


