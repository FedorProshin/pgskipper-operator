# Copyright 2024-2025 NetCracker Technology Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

rules=()
readarray -t rules < <(yq eval '.groups[].rules[].alert' ./rules.yaml)
tests=()
readarray -t tests < <(yq '.tests[].alert_rule_test[].alertname' ./test.yaml)
errorrules=()
errorcount=()
i=0

for item in "${rules[@]}"; do
count=0

	for j in "${tests[@]}"; do
	if [[ "$j" == "$item" ]]; then
	((count++))
	fi
	done
if [[ "$count" -lt 2 ]]; then
errorrules[i]="$item"
errorcount[i]="$count"
((i++))
fi
done

if [[ "$i" -gt 0 ]]; then
echo "This alert rules dont have all required tests (minimum 2 tests per rule needed):"
	for k in "${!errorrules[@]}"; do
	  echo	"Alert: ${errorrules[k]}, Tests found: ${errorcount[k]}"
	done
exit 1
else
echo "All alert rules has required tests"
exit 0
fi