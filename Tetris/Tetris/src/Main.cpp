#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <iostream>
using namespace std;

const int width = 640;
const int height = 480;

const int M = 20;
const int N = 10;
const float FPS = 1;

int field[M][N] = {0};

struct Point
{int x,y;} a[4], b[4];

int figures[7][4] =
{
	1,3,5,7, // I
	2,4,5,7, // Z
	3,5,4,6, // S
	3,5,4,7, // T
	2,3,5,7, // L
	3,5,7,6, // J
	2,3,4,5, // O
};

bool check()
{
   for (int i=0;i<4;i++)
	  if (a[i].x<0 || a[i].x>=N || a[i].y>=M) return 0;
      else if (field[a[i].y][a[i].x]) return 0;

   return 1;
};

int main()
{
    al_init();
    al_install_keyboard();
    al_init_image_addon();

    //ALLEGRO_KEYBOARD_STATE kayboard;
    ALLEGRO_DISPLAY *display  = al_create_display(width, height);
    al_set_window_title( display,"Bitmapy");
    ALLEGRO_BITMAP *tile = al_load_bitmap("images/tiles.png");//Wczytywanie obrazka

    ALLEGRO_TIMER *timer = al_create_timer(1.0 / FPS);

    ALLEGRO_EVENT_QUEUE *event_queue = al_create_event_queue();
    al_register_event_source(event_queue, al_get_display_event_source(display));
    al_register_event_source(event_queue, al_get_timer_event_source(timer));
    al_register_event_source(event_queue, al_get_keyboard_event_source());
    ALLEGRO_EVENT event;

    al_start_timer(timer);

    int dx=0; bool rotate=0; int colorNum=1;
	float delay=0.3;

    bool running = true;

    while(running)
    {
        al_get_next_event(event_queue, &event);
        if(event.type == ALLEGRO_EVENT_DISPLAY_CLOSE) return 0;

        //kolor okna
        al_clear_to_color(al_map_rgb(255,255,255));

        al_wait_for_event(event_queue, &event);

        //int n = 3;
        //if(a[0].x==0)
        //for(int i=0;i<4;i++)
        //{
          //  a[i].x = figures[n][i] % 2;
            //a[i].y = figures[n][i] / 2;
        //}


        switch(event.keyboard.keycode)
        {
            case ALLEGRO_KEY_LEFT:
            dx = -1;
            break;
            case ALLEGRO_KEY_RIGHT:
            dx = 1;
            break;
            case ALLEGRO_KEY_UP:
            rotate = true;
            break;
        }

        // Poruszanie kszta³tu
        for (int i=0;i<4;i++)  { b[i]=a[i]; a[i].x+=dx; }
        if (!check()) for (int i=0;i<4;i++) a[i]=b[i];

        // Obracanie kszta³u
        if (rotate)
          {
            Point p = a[1]; //center of rotation
            for (int i=0;i<4;i++)
              {
                int x = a[i].y-p.y;
                int y = a[i].x-p.x;
                a[i].x = p.x - x;
                a[i].y = p.y + y;
              }
            if (!check()) for (int i=0;i<4;i++) a[i]=b[i];
          }

        // Poruszanie obiektu w dó³

            for (int i=0;i<4;i++) { b[i]=a[i]; a[i].y+=1; }

            if (!check())
            {
             for (int i=0;i<4;i++) field[b[i].y][b[i].x]=colorNum;

             colorNum=1+rand()%7;
             int n=rand()%7;
             for (int i=0;i<4;i++)
               {
                a[i].x = figures[n][i] % 2;
                a[i].y = figures[n][i] / 2;
               }
            }

        // Sprawdzenie czy kszta³t przektoczy³ wyznaczony obszar
        int k=M-1;
        for (int i=M-1;i>0;i--)
        {
            int count=0;
            for (int j=0;j<N;j++)
            {
                if (field[i][j]) count++;
                field[k][j]=field[i][j];
            }
            if (count<N) k--;
        }

        dx=0; rotate=0; delay=0.3;

        // Rysuj kszta³t

	for (int i=0;i<M;i++)
	 for (int j=0;j<N;j++)
	   {
            if (field[i][j]==0) continue;
            al_draw_bitmap_region(tile, field[i][j]*18, 0, 18,18,j*18,i*18,0);
	   }

	   	for (int i=0;i<4;i++)
	  {
		al_draw_bitmap_region(tile,colorNum*18, 0, 18,18,a[i].x*18,a[i].y*18,0);
	  }

        al_flip_display();
        al_clear_to_color(al_map_rgb(255,255,255));
        al_rest(0.001);//pauza
    }

    al_destroy_display(display);
    al_destroy_timer(timer);

    return 0;
}
