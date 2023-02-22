# Maven Code Review

This action analyzes your **Java** code with sonarcloud for **maven**.

👀 **Important!**

Remember to
add [jacoco plugin](https://github.com/pagopa/template-java-spring-microservice/blob/main/pom.xml#LL118-L153C16) in your
pom.xml to calculate the coverage.

## Usage

``` yaml
- name: Code Review
  uses: pagopa/github-actions-template/maven-code-review@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    sonar_token: ${{ secrets.SONAR_TOKEN }}
    project_key: pagopa_project-key
    coverage_exclusions: "**/config/*,**/*Mock*,**/model/**,**/entity/*"
    cpd_exclusions: "**/model/**,**/entity/*"
      
```

## Input

| Param               | Description                            | Required | Values   | Default                                         |
|---------------------|----------------------------------------|----------|----------|-------------------------------------------------|
| project_key         | The key of the project on SonarCloud   | **true** | `string` |                                                 |
| github_token        | A GitHub token                         | **true** | `string` |                                                 |
| sonar_token         | The Sonar token                        | **true** | `string` |                                                 |
| coverage_exclusions | Files to exclude from coverage         | false    | `string` | "**/config/*,**/*Mock*,**/model/**,**/entity/*" |
| cpd_exclusions      | Files to exclude from code duplication | false    | `string` | **/model/**,**/entity/*"                        |

## Output

N.A.
