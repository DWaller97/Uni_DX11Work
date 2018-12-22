#pragma once
#include "Object.h"
class Car :
	public Object
{
private:
	float velocity = 5;
	float maxVelocity = 60;

	float acceleration = 1;
public:
	void SetVelocity(float amount);
	float GetVelocity() { return velocity; };

	void TurnRight(float amount);
	void TurnLeft(float amount);
	virtual void Update(float deltaTime) override;
	Car();
	~Car();
};
