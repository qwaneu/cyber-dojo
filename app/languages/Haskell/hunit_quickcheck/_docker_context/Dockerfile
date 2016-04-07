FROM      haskell:7.10.3 
MAINTAINER Willem van den Ende (willem@qwan.eu)

# -D=no password -H=no home directory
RUN adduser -D -H -u 19661 cyber-dojo

RUN cabal update && cabal install --global hspec hunit QuickCheck 

