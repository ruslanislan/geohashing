List<int> givenHash(String hashBinString) {
return [int.parse(hashBinString, radix: 2), hashBinString.length];
}