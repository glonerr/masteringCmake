#include <iostream>
using namespace std;

class Shape
{
  public:
    //  virtual void draw() {
    void draw()
    {
        cout << "draw Shape" << endl;
    }
};

class Circle : public Shape
{
  public:
    //  virtual void draw() {
    void draw()
    {
        cout << "draw Circle" << endl;
    }
};

int main()
{
    Shape *s = new Circle();
    s->draw();
}