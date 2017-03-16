# STORM #
* Storm-Node init.pp
  * install maven
  * install java-8 and set it as $JAVA_HOME   ->    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
  * mvn package and move jar

  * input from kafka
    * simply use the kafka client (as used before) instead of the storm xy-spout ?!
      * > read only one line at a time

  * output to DASHING.IO 
    * Anleitung (setup auf dem host)
      * install ruby 
      * $ gem install dashing
      * $ gem install bundler
      * add to $PATH
      * cd into dashing project
      * $ bundle
      * $ dashing start
    * EXAMPLE command:
      * curl -d '{ "auth_token": "pageviewskey", "items":[ {"label":"testentry2","value":"5"}] }' \http://localhost:3030/widgets/pageviews
      * auf VM wird Adresse durch 10.0.2.2 ersetzt (gateway zu vm host)  
# reader #
  > zweites widget anlegen, das den output des batch processings anzeigt?

# FINALE #
* CLEANUP
  * eine parent pom für alle projekte?
  * remove tar.gz files etc. from puppet directories
  * remove "local test" sections from init.pp's and activate "real downloads"
  
* TEST TEST TEST :) (mit echten und finalen files etc.)
