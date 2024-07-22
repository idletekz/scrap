import math
from collections import Counter

# Count the frequency of each unique character.
# Calculate the probability of each character.
# Sum the product of the probability and the logarithm of the probability.
# Multiply by -1 to get the final entropy value.
def shannon_entropy(string):
    # Count the frequency of each character in the string
    freq = Counter(string)
    # Total number of characters in the string
    length = len(string)
    # Calculate the Shannon entropy
    entropy = -sum((count / length) * math.log2(count / length) for count in freq.values())
    return entropy

# Example usage:
input_string = "hello world"
entropy = shannon_entropy(input_string)
print(f"Shannon entropy of '{input_string}' is: {entropy}")
