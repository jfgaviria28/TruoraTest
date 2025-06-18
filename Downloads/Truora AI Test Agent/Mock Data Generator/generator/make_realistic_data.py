#!/usr/bin/env python3
"""
Generate realistic (messy) mock data for testing AI data pipelines.
Combines original data generation with entropy additions.
"""

import subprocess
import sys
from pathlib import Path

def main():
    """Generate clean data, then add realistic entropy"""
    
    print("🏭 Generating realistic mock data...")
    print("=" * 50)
    
    # Step 1: Generate clean data
    print("📊 Step 1: Generating base clean data...")
    try:
        result = subprocess.run([sys.executable, "make_data.py"], 
                              capture_output=True, text=True, check=True)
        print(result.stdout.strip())
    except subprocess.CalledProcessError as e:
        print(f"❌ Error generating base data: {e}")
        return False
    
    print("\n🧬 Step 2: Adding realistic entropy...")
    
    # Step 2: Add entropy
    try:
        result = subprocess.run([sys.executable, "add_entropy.py"], 
                              capture_output=True, text=True, check=True)
        
        # Print only the important lines, filter out pandas warnings
        lines = result.stdout.split('\n')
        for line in lines:
            if not line.startswith('/') and not 'FutureWarning' in line and line.strip():
                print(line)
                
    except subprocess.CalledProcessError as e:
        print(f"❌ Error adding entropy: {e}")
        return False
    
    print("\n" + "=" * 50)
    print("✅ Realistic mock data generated!")
    print("📁 Files created in: ./data/")
    print("\n🎯 Your data now includes:")
    print("  • Mixed column names & cases")
    print("  • Multiple currencies (USD/COP/MXN)")  
    print("  • Different date formats")
    print("  • Missing/null values")
    print("  • Duplicate records with typos")
    print("  • Key mismatches")
    print("\n📖 See ENTROPY_SUMMARY.md for full details")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 