void setup() {
  // put your setup code here, to run once:
   
   char dest[] = "Ian was here";
   const char src[]  = "This is a long line of text to test memmove";
    Serial.begin(9600);
   printf("Before memmove dest = %s, src = %s\n", dest, src);
   memmove(dest, src, 9);
   printf("After memmove dest = %s, src = %s\n", dest, src);


}

void loop() {
  // put your main code here, to run repeatedly:

}
