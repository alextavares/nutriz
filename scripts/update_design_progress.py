#!/usr/bin/env python3
import json, sys, time, os

PLAN_PATH = os.path.join('docs', 'redesign_yazio_like.plan.json')

USAGE = (
    "Usage:\n"
    "  python3 scripts/update_design_progress.py set <step_id> <status> [note...]\n"
    "Statuses: pending | in_progress | completed\n"
)

def load_plan():
    if not os.path.exists(PLAN_PATH):
        return {"title": "NutriTracker UI Redesign — YAZIO-like", "created": time.strftime('%Y-%m-%dT%H:%M:%SZ'), "updated": time.strftime('%Y-%m-%dT%H:%M:%SZ'), "steps": [], "notes": []}
    with open(PLAN_PATH, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_plan(plan):
    plan['updated'] = time.strftime('%Y-%m-%dT%H:%M:%SZ')
    with open(PLAN_PATH, 'w', encoding='utf-8') as f:
        json.dump(plan, f, indent=2, ensure_ascii=False)

def set_status(step_id, status, note=None):
    plan = load_plan()
    valid = {"pending", "in_progress", "completed"}
    if status not in valid:
        print(USAGE);
        sys.exit(1)
    matched = False
    for step in plan.get('steps', []):
        if step.get('id') == step_id:
            step['status'] = status
            matched = True
            break
    if not matched:
        plan.setdefault('steps', []).append({"id": step_id, "name": step_id, "status": status})
    if note:
        plan.setdefault('notes', []).append({"ts": time.strftime('%Y-%m-%dT%H:%M:%SZ'), "step": step_id, "note": note})
    save_plan(plan)
    print(f"Updated {step_id} -> {status}")

def main():
    if len(sys.argv) < 2:
        print(USAGE); sys.exit(1)
    cmd = sys.argv[1]
    if cmd == 'set' and len(sys.argv) >= 4:
        step_id = sys.argv[2]
        status = sys.argv[3]
        note = " ".join(sys.argv[4:]) if len(sys.argv) > 4 else None
        set_status(step_id, status, note)
    else:
        print(USAGE); sys.exit(1)

if __name__ == '__main__':
    main()

