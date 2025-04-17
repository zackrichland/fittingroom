import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://ygdbjyhtlzdkwhczvfpb.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlnZGJqeWh0bHpka3doY3p2ZnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQyMzcxNzEsImV4cCI6MjA1OTgxMzE3MX0.3Sw1EX8CxqZntQAvN7FzkbiND9dGCANG1RqU_UlmPo8"
) 